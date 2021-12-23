<template>
  <b-container class="mb-5">
    <b-row class="header-row">
      <b-col>
        <h1>CryptoVipers</h1>

        <p>Collect and breed digital vipers.</p>
      </b-col>
    </b-row>

    <b-row>
      <b-col class="action-row text-center">
        <h4>Buy a random Viper</h4>

        <img
          :src="unknownViperImage"
          class="unknown-viper"
          alt="unknown viper"
        />

        <b-button type="button" @click="buyViper"> Buy </b-button>

        <p>Each Viper costs 0.02 Ether</p>
      </b-col>

      <b-col cols="12" class="middle-container">
        <img
          v-if="isLoading"
          src="https://media.giphy.com/media/2A6xoqXc9qML9gzBUE/giphy.gif"
          alt="loading"
        />

        <h3 v-else>or</h3>
      </b-col>

      <b-col class="action-container">
        <h4>Breed two of the Vipers you own to make a new one!</h4>

        <b-form id="form-breed-vipers" @submit.prevent="breedVipers">
          <b-form-group id="matron" label="Matron ID:" label-for="matron">
            <b-form-input
              v-model="matron"
              id="matron"
              required
              placeholder="Enter matron ID"
            >
            </b-form-input>
          </b-form-group>

          <b-form-group id="sire" label="Sire ID:" label-for="sire">
            <b-form-input
              v-model="sire"
              id="sire"
              required
              placeholder="Enter sire ID"
            >
            </b-form-input>
          </b-form-group>

          <b-button type="submit" form="form-breed-vipers">
            Breed Vipers
          </b-button>

          <p>Breeding Vipers cost 0.05 Ether</p>
        </b-form>
      </b-col>
    </b-row>

    <hr />

    <h2 class="mb-5">Owned Vipers</h2>

    <template v-if="vipers.length">
      <b-row v-for="i in Math.ceil(vipers.length / 3)" :key="i">
        <b-col
          cols="4"
          v-for="item in vipers.slice((i - 1) * 3, i * 3)"
          :item="item"
          :key="item.id"
        >
          <b-card style="height: 400px" class="mb-2">
            <b-img thumbnail fluid :src="item.url" class="image"></b-img>

            <p class="card-text mt-2 text-center">
              <b>ID: </b> {{ item.id }}

              <br />

              <b>Origin: </b>

              <span v-if="item.matron === '0' && item.sire === '0'">
                Bought
              </span>

              <span v-else>{{ item.matron }} & {{ item.sire }}</span>
            </p>
          </b-card>
        </b-col>
      </b-row>
    </template>

    <b-row v-else>
      <b-col>
        <h2>No Vipers owned yet!</h2>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import getWeb3 from "@/contracts/web3";
import contractAbi from "@/contracts/abi";
import Viper1 from "@/assets/Viper/1.png";
import Viper2 from "@/assets/Viper/2.png";
import Viper3 from "@/assets/Viper/3.png";
import Viper4 from "@/assets/Viper/4.png";
import Viper5 from "@/assets/Viper/5.png";
import Viper6 from "@/assets/Viper/6.png";
import ViperX from "@/assets/Viper/unknown.png";

const contractAddress = "0x3129C030c883444330B9F2e624052813Ecb5BeF9";

const vipersMap = [null, Viper1, Viper2, Viper3, Viper4, Viper5, Viper6];

export default {
  name: "App",

  data() {
    return {
      web3: null,
      account: null,
      contractInstance: null,
      gene: null,
      matron: null,
      sire: null,
      unknownViperImage: ViperX,
      vipers: [],
      isLoading: false,
    };
  },

  async mounted() {
    try {
      this.web3 = await getWeb3();

      this.contractInstance = new this.web3.eth.Contract(
        contractAbi,
        contractAddress
      );

      [this.account] = await this.web3.eth.getAccounts();

      await this.getVipers();
    } catch (error) {
      console.error(error);
    }
  },

  methods: {
    async buyViper() {
      this.isLoading = true;

      try {
        const receipt = await this.contractInstance.methods.buyViper().send({
          from: this.account,
          value: this.web3.utils.toWei("0.02", "ether"),
        });

        this.addViperFromReceipt(receipt);
      } catch (error) {
        console.error(error);
      }

      this.isLoading = false;
    },
    async breedVipers() {
      this.isLoading = true;

      try {
        const receipt = await this.contractInstance.methods
          .breedVipers(this.matron, this.sire)
          .send({
            from: this.account,
            value: this.web3.utils.toWei("0.05", "ether"),
          });

        this.addViperFromReceipt(receipt);

        this.matron = null;

        this.sire = null;
      } catch (error) {
        console.error(error);
      }

      this.isLoading = false;
    },
    async getVipers() {
      this.isLoading = true;

      try {
        const receipts = await this.contractInstance.methods
          .ownedVipers()
          .call({
            from: this.account,
          });

        for (let i = 0; i < receipts.length; i++) {
          const viper = await this.contractInstance.methods
            .getViperDetails(receipts[i])
            .call({
              from: this.account,
            });

          this.vipers.push({
            id: viper[0],
            genes: viper[1],
            matron: viper[2],
            sire: viper[2],
            url: vipersMap[viper[1]],
          });
        }
      } catch (error) {
        console.error(error);
      }

      this.isLoading = false;
    },
    addViperFromReceipt(receipt) {
      this.vipers.push({
        id: receipt.events.Birth.returnValues.viperId,
        genes: receipt.events.Birth.returnValues.genes,
        matron: receipt.events.Birth.returnValues.matronId,
        sire: receipt.events.Birth.returnValues.sireId,
        url: vipersMap[receipt.events.Birth.returnValues.genes],
      });
    },
  },
};
</script>

<style lang="scss">
@import url("https://fonts.googleapis.com/css?family=Poppins:400,500");

* {
  font-family: "Poppins", sans-serif;
}

button {
  width: 100%;
}

.header-row {
  text-align: center;
  margin: 30px 0;
}

.action-container {
  h4 {
    text-align: center;
    margin-bottom: 30px;
  }

  p {
    text-align: center;
    margin-top: 10px;
  }
}

.middle-container {
  display: flex;
  justify-content: center;
  align-items: center;

  img {
    height: 100px;
  }
}

.unknown-viper {
  height: 180px;
  width: 180px;
  margin: 9px 0;
}
</style>

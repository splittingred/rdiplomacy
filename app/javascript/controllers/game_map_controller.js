import { Controller } from "@hotwired/stimulus"
import MapUI from "../lib/map_ui"

// Connects to data-controller="game-map"
export default class extends Controller {
  connect() {
    const mapUi = new MapUI();
  }
}

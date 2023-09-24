
export default class MapUI {
    #units
    #territories
    #currentUnit
    #activeMapNode
    #activeTerritoryAbbr
    #svgNs
    #xlinkNs
    #svgDoc

    constructor() {
        this.#units = window.rDipUnits || {}
        this.#territories = window.rDipTerritories || {}
        const mapUi = this
        const svg = $("#map-container > svg");
        $("g#MouseLayer > path").on("click", function() {
            mapUi.startOrder($(this).attr('id'))
        });
        this.#svgDoc = svg.get(0)
        this.#svgNs = this.#svgDoc.namespaceURI
        this.#xlinkNs = svg.attr("xmlns:xlink")
    }

    getSvgElem(q) {
        return this.#svgDoc.querySelector(q)
    }

    isOrderStarted() {
        return this.#currentUnit !== undefined && this.#activeMapNode !== undefined
    }

    startOrder(clickedTerritoryAbbr) {
        const clickedMapNode = this.getSvgElem('g#MapLayer > #_' + clickedTerritoryAbbr);
        if (this.isOrderStarted()) {
            // TODO: Check if move already started
            if (this.#activeTerritoryAbbr === clickedTerritoryAbbr) {
                this.addHoldOrder(clickedMapNode, this.#currentUnit);
            } else {
                this.addMoveOrder(clickedMapNode, this.#currentUnit, clickedTerritoryAbbr);
            }
            this.finishOrder();
        } else {
            this.selectTerritory(clickedTerritoryAbbr, clickedMapNode);
        }
    }

    selectTerritory(clickedTerritoryAbbr, clickedMapNode) {
        this.#currentUnit = this.#units[clickedTerritoryAbbr];
        if (this.#currentUnit !== undefined) {
            // we clicked an actual unit
            this.#activeTerritoryAbbr = clickedTerritoryAbbr;
            this.makeActiveMapNode(clickedMapNode)
        }
    }

    makeActiveMapNode(node) {
        $(node).css("fill", "rgb(250, 72, 28)")
        this.#activeMapNode = node;
    }

    finishOrder() {
        this.#currentUnit = undefined;
        this.removeActiveMapNode(this.#activeMapNode)
    }

    removeActiveMapNode(node) {
        $(node).css("fill", "")
        this.#activeMapNode = undefined;
    }

    removeExistingOrder(unit) {
        console.log("map-order-" + unit.unit_territory_abbr)
        let els = document.getElementsByClassName("map-order-" + unit.unit_territory_abbr);
        console.log(els)
        while (els[0]) {
            els[0].parentNode.removeChild(els[0]);
        }
    }

    addHoldOrder(node, unit) {
        this.removeExistingOrder(unit)

        const layerElem = this.getSvgElem('g#Layer2');
        const gElem = document.createElementNS(this.#svgNs, "g");
        gElem.setAttribute( "stroke", unit.country_color);
        const useElem = document.createElementNS(this.#svgNs, "use");
        useElem.setAttribute( "x", (unit.unit_territory_x - (50 / 5).toString()));
        // useElem.setAttribute( "x", (territory.unit_x - (50 / 5).toString()));
        useElem.setAttribute( "y", (unit.unit_territory_y - (50 / 4).toString()));
        useElem.setAttribute("height", "75");
        useElem.setAttribute("width", "75");
        useElem.setAttributeNS(this.#xlinkNs, "href", '#HoldUnit');
        gElem.appendChild(useElem);
        layerElem.appendChild(gElem);
    }

    addMoveOrder(node, unit, clickedTerritoryId) {
        this.removeExistingOrder(unit)

        let layerElem = this.getSvgElem('g#Layer2');
        let gElem = document.createElementNS(this.#svgNs, "g");

        let to_territory = this.#territories[clickedTerritoryId];
        let coords = this.determineMoveCoordinates(unit.unit_territory_x, unit.unit_territory_y, to_territory.unit_x, to_territory.unit_y, unit.unit_width, unit.unit_height)

        const lineWithShadowElem = document.createElementNS(this.#svgNs, "line");
        lineWithShadowElem.setAttribute("x1", coords.from_x);
        lineWithShadowElem.setAttribute("y1", coords.from_y);
        lineWithShadowElem.setAttribute("x2", coords.to_x);
        lineWithShadowElem.setAttribute("y2", coords.to_y);
        lineWithShadowElem.setAttribute("class", "varwidthshadow map-order-" + unit.unit_territory_abbr);
        lineWithShadowElem.setAttribute("stroke-width", "10");

        const lineWithArrowElem = document.createElementNS(this.#svgNs, "line");
        lineWithArrowElem.setAttribute("x1", coords.from_x);
        lineWithArrowElem.setAttribute("y1", coords.from_y);
        lineWithArrowElem.setAttribute("x2", coords.to_x);
        lineWithArrowElem.setAttribute("y2", coords.to_y);
        lineWithArrowElem.setAttribute("class", "varwidthorder map-order-" + unit.unit_territory_abbr);
        lineWithArrowElem.setAttribute("stroke", unit.country_color);
        lineWithArrowElem.setAttribute("stroke-width", "5");
        lineWithArrowElem.setAttribute("marker-end", "url(#arrow)");

        gElem.appendChild(lineWithShadowElem);
        gElem.appendChild(lineWithArrowElem);
        layerElem.appendChild(gElem);
        /*

      from_x, from_y, to_x, to_y = determine_move_coordinates(from: from_territory, to: to_territory, unit_type:)
         */
    }

    determineMoveCoordinates(from_x, from_y, to_x, to_y, width, height) {
        from_x = from_x + (width / 2)
        from_y = from_y + (height / 2)
        let delta_x = to_x - from_x
        let delta_y = to_y - from_y
        let vector_length = ((delta_x**2) + (delta_y**2))**0.6
        let delta_dec = (width / 2) + (2 * 0.5)
        to_x = this.roundToHundredths(from_x + ((vector_length - delta_dec) / vector_length * delta_x));
        to_y = this.roundToHundredths(from_y + ((vector_length - delta_dec) / vector_length * delta_y));
        return {
            from_x: from_x,
            from_y: from_y,
            to_x: to_x,
            to_y: to_y
        }
    }

    roundToHundredths(num) {
        return Math.round((num + Number.EPSILON) * 100) / 100;
    }
}

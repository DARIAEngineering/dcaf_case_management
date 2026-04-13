import { application } from "./application"

import FlashController from "./flash_controller"
application.register("flash", FlashController)

import ModalController from "./modal_controller"
application.register("modal", ModalController)

import TableSortController from "./table_sort_controller"
application.register("table-sort", TableSortController)

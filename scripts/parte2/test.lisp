;; ================================================================
;; PROBLEMA DE EJEMPLO — verifica las situaciones del enunciado
;; ================================================================
;; Escenario:
;;   - 1 dron en depot
;;   - 2 localizaciones: loc1 (necesita 3 food + 2 medicine = 5)
;;                        loc2 (necesita 1 food + 1 medicine = 2)
;;   - 2 carriers: carrier-big (cap 8), carrier-small (cap 3)
;;   - Stock en depot: 10 food, 10 medicine
;;
;; Situaciones cubiertas:
;;   * carrier-big >= total_need(loc1)=5 → se elige carrier-small (cap=3, mínimo que cubre 5 NO, 3<5)
;;     → ninguno cubre loc1 individualmente → se elige carrier-big (mayor)   [regla mayor]
;;   * carrier-big (cap=8) >= need(loc1)+need(loc2)=7 → multi-loc posible    [regla multi-loc]
;;   * Al volver a depot con restos, se entregan sueltos si quedan            [regla restos]
;; ================================================================

(defproblem emergency-test emergency-advanced

  ;; Estado inicial
  (
   ;; Dron
   (at-drone drone1 depot)
   (drone-free drone1)

   ;; Carriers en depot
   (at-carrier carrier-big depot)
   (at-carrier carrier-small depot)
   (carrier-capacity carrier-big 8)
   (carrier-capacity carrier-small 3)
   (carrier-free-space carrier-big 8)
   (carrier-free-space carrier-small 3)
   (carrier-stock carrier-big food 0)
   (carrier-stock carrier-big medicine 0)
   (carrier-stock carrier-small food 0)
   (carrier-stock carrier-small medicine 0)

   ;; Stock en depot
   (location-stock depot food 10)
   (location-stock depot medicine 10)

   ;; Necesidades de localizaciones
   (location-need loc1 food 3)
   (location-need loc1 medicine 2)
   (location-total-need loc1 5)

   (location-need loc2 food 1)
   (location-need loc2 medicine 1)
   (location-total-need loc2 2)

   ;; Stock en localizaciones (inicialmente 0)
   (location-stock loc1 food 0)
   (location-stock loc1 medicine 0)
   (location-stock loc2 food 0)
   (location-stock loc2 medicine 0)
  )

  ;; Tarea raíz
  ((enviar-todo))
)

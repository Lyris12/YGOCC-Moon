--Calling of the Divine Blade
function c88567312.initial_effect(c)
  --activate
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(88567312,0))
  e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,88567312+EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(c88567312.chth)
  e1:SetOperation(c88567312.chop)
  c:RegisterEffect(e1)
end
function c88567312.chfilter(c)
  return c:IsSetCard(0x1bc2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c88567312.chth(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(c88567312.chfilter,tp,LOCATION_DECK,0,3,nil) end
  Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
  Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function c88567312.chop(e,tp,eg,ep,ev,re,r,rp)
  local g=Duel.GetMatchingGroup(c88567312.chfilter,tp,LOCATION_DECK,0,nil)
  if g:GetCount()>=3 then
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
  local sg=g:Select(tp,3,3,nil)
  Duel.ConfirmCards(1-tp,sg)
  local tg=sg:RandomSelect(1-tp,1)
  Duel.SendtoHand(tg,nil,REASON_EFFECT)
  end
end

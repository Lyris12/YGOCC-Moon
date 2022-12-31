--Mezka Downfall
function c31157202.initial_effect(c)
  --Excavate
  local e1=Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(31157202,0))
  e1:SetCategory(CATEGORY_TOHAND)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCountLimit(1,31157202+EFFECT_COUNT_CODE_OATH)
  e1:SetTarget(c31157202.excatg)
  e1:SetOperation(c31157202.excaop)
  c:RegisterEffect(e1)
  --mill
  local e2=Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(31157202,1))
  e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_REMOVE)
  e2:SetCondition(c31157202.thcon)
  e2:SetTarget(c31157202.thtg)
  e2:SetOperation(c31157202.thop)
  c:RegisterEffect(e2)
end
function c31157202.excafilter(c)
  return c:IsFaceup() and c:IsSetCard(0xc70) and c:IsType(TYPE_MONSTER)
end
function c31157202.excatg(e,tp,eg,ep,ev,re,r,rp,chk)
  local ct=Duel.GetMatchingGroupCount(c31157202.excafilter,tp,LOCATION_MZONE,0,nil)
  if chk==0 then return Duel.IsExistingMatchingCard(c31157202.excafilter,tp,LOCATION_MZONE,0,1,nil)
  and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct end
  e:SetLabel(ct)
  Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
  Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function c31157202.excaop(e,tp,eg,ep,ev,re,r,rp)
  local ct=e:GetLabel()
  Duel.ConfirmDecktop(tp,ct)
  local g=Duel.GetDecktopGroup(tp,ct)
  if g:GetCount()>0 then
    Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
    local sg=g:Select(tp,1,1,nil)
    if sg:GetFirst():IsAbleToHand() then
      Duel.SendtoHand(sg,nil,REASON_EFFECT)
      Duel.ConfirmCards(1-tp,sg)
      Duel.ShuffleHand(tp)
    else
      Duel.SendtoGrave(sg,REASON_RULE)
    end
  Duel.ShuffleDeck(tp)
  end
end
function c31157202.thcon(e,tp,eg,ep,ev,re,r,rp)
    if not re then return false end
    local rc=re:GetHandler()
    return e:GetHandler():IsReason(REASON_EFFECT) and rc:IsSetCard(0xc70) and rc:IsType(TYPE_MONSTER)
end
function c31157202.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
function c31157202.thfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c31157202.thop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
    Duel.ConfirmDecktop(tp,5)
    local g=Duel.GetDecktopGroup(tp,5)
    if g:GetCount()>0 then
        Duel.DisableShuffleCheck()
        if g:IsExists(c31157202.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(31157202,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:FilterSelect(tp,c31157202.thfilter,1,1,nil)
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
            Duel.ShuffleHand(tp)
            g:Sub(sg)
        end
        Duel.SortDecktop(tp,tp,g:GetCount())
    end
end
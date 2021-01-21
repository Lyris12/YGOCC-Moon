--Moonvale Apprentice
function c10505096.initial_effect(c)
	  c:EnableReviveLimit()
	  --banish shit
	  local e1=Effect.CreateEffect(c)
	  e1:SetDescription(aux.Stringid(10505096,0))
	  e1:SetCategory(CATEGORY_REMOVE)
	  e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	  e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	  e1:SetCountLimit(1,10505096)
	  e1:SetCondition(c10505096.tgcon)
	  e1:SetTarget(c10505096.tgtg)
	  e1:SetOperation(c10505096.tgop)
	  c:RegisterEffect(e1)
	  --set
	  local e2=Effect.CreateEffect(c)
	  e2:SetDescription(aux.Stringid(10505096,0))
	  e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	  e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	  e2:SetCode(EVENT_TO_GRAVE)
	  e2:SetCountLimit(1,10506096)
	  e2:SetCondition(c10505096.setcon)
	  e2:SetTarget(c10505096.settg)
	  e2:SetOperation(c10505096.setop)
	  c:RegisterEffect(e2)
end
function c10505096.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
end
function c10505096.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function c10505096.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
function c10505096.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
function c10505096.filter(c)
	return c:IsSetCard(0x1a5) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function c10505096.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c10505096.filter,tp,LOCATION_DECK,0,1,nil) end
end
function c10505096.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c10505096.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then Duel.SSet(tp,g:GetFirst()) end
end
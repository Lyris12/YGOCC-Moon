--Oak Loupine
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
   aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,1)
	aux.AddEvoluteProc(c,nil,3,cid.filter2,1,1)
	--to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.drcost)
	e1:SetTarget(cid.thtg)
	e1:SetOperation(cid.thop)
	c:RegisterEffect(e1)
	--immune
	--atkup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cid.val)
	c:RegisterEffect(e2)
end
function cid.filter2(c,ec,tp)
	return c:IsRace(RACE_PLANT) and not c:IsCode(id) 
end
function cid.filter1(c,ec,tp)
	return c:IsRace(RACE_PLANT) 
end
function cid.filter(c)
	return c:IsRace(RACE_PLANT) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_DECK,0,1,nil) end
end
function cid.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		else
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
function cid.val(e,c)
	return Duel.GetMatchingGroupCount(cid.filter2,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)*100
end
function cid.filter2(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
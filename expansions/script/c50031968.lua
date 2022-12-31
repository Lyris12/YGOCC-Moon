--Gift of the Gifted Bats
local cid,id=GetID()
function cid.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,nil,6,cid.mfilter,2,99)  
	--Conjoint Procedure
	aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,2)  
   local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(cid.mttg)
	e1:SetOperation(cid.mtop)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCost(cid.cost)
	e2:SetTarget(cid.rmtg)
	e2:SetOperation(cid.rmop)
	c:RegisterEffect(e2)
end
function cid.mfilter(c,e)
   return c:IsRace(RACE_ZOMBIE) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function cid.mtfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsFaceup() and c:IsCanOverlay()
end
function cid.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_CONJOINT)
		and Duel.IsExistingMatchingCard(cid.mtfilter,tp,LOCATION_REMOVED,0,1,nil) end
end
function cid.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,cid.mtfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_OVERLAY) and tc:GetOriginalType()&TYPE_EVOLUTE~=0 then
			Duel.Recover(tp,1000,REASON_EFFECT)
		end
	end
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveEC(tp,4,REASON_COST) end
	c:RemoveEC(tp,4,REASON_COST)
end
function cid.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function cid.desfilterxx(c)
	return c:IsFaceup() and c:IsAbleToGrave()
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)

if tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_MONSTER) and tc:IsRace(RACE_ZOMBIE) and not tc:IsAttribute(ATTRIBUTE_LIGHT) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,cid.desfilterxx,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			Duel.HintSelection(g)
			Duel.SendtoGrave(g,nil,REASON_EFFECT)
		end
	end
end
end
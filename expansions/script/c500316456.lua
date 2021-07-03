--Supa-Paintress Guerricore
--Created by Chadook
--Scripted by Chadook
function c500316456.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,6,c500316456.filter1,1)
		--sp summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(500316456,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetHintTiming(0,0x11e0)
	e3:SetCode(EVENT_FREE_CHAIN)
	--e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c500316456.adcost)
	e3:SetTarget(c500316456.target)
	e3:SetOperation(c500316456.operation)
	c:RegisterEffect(e3)
end
function c500316456.checku(sg,ec,tp)
return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function c500316456.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsRace(RACE_FAIRY)
end
function c500316456.filter(c,e,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c500316456.desfilter(c)
	return c:IsFaceup() and bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)~=0 
		and not c:IsType(TYPE_NORMAL) and c:IsDestructable()
end
function c500316456.costfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_NORMAL) and (c:IsType(TYPE_PENDULUM) and c:IsFaceup())
end
function c500316456.adcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) and Duel.IsExistingMatchingCard(c500316456.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c500316456.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end

function c500316456.cfilter(c)
	return  not c:IsType(TYPE_EFFECT) and c:IsAbleToRemoveAsCost()
end
function c500316456.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_HAND) and chkc:IsControler(tp) and c500316456.filter(chkc,e,tp) and  Duel.IsPlayerCanDraw(tp,1) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(c500316456.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c500316456.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c500316456.zzfilter(c)
	return c:IsFaceup() and  c:IsType(TYPE_EFFECT)and bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)==SUMMON_TYPE_SPECIAL and c:IsAbleToRemove() 
end
function c500316456.operation(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	if tc:IsSetCard(0xc50) and tc:IsType(TYPE_MONSTER) then
Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,c500316456.zzfilter,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			Duel.HintSelection(g)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
end



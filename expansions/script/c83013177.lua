--Seatector Admiral
function c83013177.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WATER),2,2)
	c:EnableReviveLimit()
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c83013177.regcon)
	e1:SetOperation(c83013177.regop)
	c:RegisterEffect(e1)
	--if it link summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83013177,0))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c83013177.seqcon)
	e2:SetTarget(c83013177.seqtg)
	e2:SetOperation(c83013177.seqop)
	c:RegisterEffect(e2)
	--discard
	local e3=Effect.CreateEffect(c)
	e3:SetCountLimit(1)
	e3:SetCategory(CATEGORY_EQUIP+CATEGORY_ATKCHANGE+CATEGORY_GRAVE_ACTION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c83013177.eqcos)
	e3:SetTarget(c83013177.eqtg)
	e3:SetOperation(c83013177.eqop)
	c:RegisterEffect(e3)
end
function c83013177.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
function c83013177.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c83013177.splimit)
	Duel.RegisterEffect(e1,tp)
end
function c83013177.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(83013177) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
function c83013177.seqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c83013177.eqfilter(c,tc,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_UNION) and aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function c83013177.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(c83013177.eqfilter,tp,LOCATION_DECK,0,1,nil,c,tp) end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function c83013177.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local eqg=Duel.SelectMatchingCard(tp,c83013177.eqfilter,tp,LOCATION_DECK,0,1,1,nil,c,tp)
	local ec=eqg:GetFirst()
	if ec and c:IsFaceup() and aux.CheckUnionEquip(ec,c) and Duel.Equip(tp,ec,c) then
		aux.SetUnionState(ec)
	end
end
function c83013177.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
function c83013177.eqcos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c83013177.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c83013177.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c83013177.eqfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x33f) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and Duel.IsExistingMatchingCard(c83013177.eqfilter2,tp,LOCATION_MZONE,0,1,nil,c)
end
function c83013177.eqfilter2(c,ec)
	return aux.CheckUnionEquip(ec,c) and ec:CheckUnionTarget(c)
end
function c83013177.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c83013177.eqfilter1(chkc,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(c83013177.eqfilter1,tp,LOCATION_GRAVE,0,1,nil,tp) end
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(c83013177.eqfilter1),tp,LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,#g,0,0)
end
function c83013177.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local g=Duel.SelectMatchingCard(tp,c83013177.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil,tc)
		local gc=g:GetFirst()
		if gc:IsFaceup() and Duel.Equip(tp,tc,gc) then
			aux.SetUnionState(tc)
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetAttack()/2)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			gc:RegisterEffect(e1)
		end
	end
end
--[[
	Seatector
	2 WATER monsters
	You can only Link summon “Seatector Admaral(s)” once per turn.
	If this card is Link Summoned: you can  equip 1 WATER Union monster from your Deck to this card.
	Once per turn: you can discard 1 WATER Monster, then target 1 “Seatector” monster in your GY: equip it to 1 of your monsters, also that  monster gain ATK equal to half equipped monsters ATK, until the end of the turn.
--]]
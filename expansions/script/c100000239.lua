--[[
Automatyrant Particle Shield
Automatiranno Scudo Particella
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is sent to the GY: You can Special Summon 1 "Automatyrant" monster from your hand, except "Automatyrant Particle Shield".]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:HOPT()
	e1:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e1)
	--[[Once per turn, you can either: Target 1 face-up Machine monster you control; equip this card to that target,
	OR: Unequip this card and Special Summon it. If the equipped monster would be destroyed by battle or card effect, destroy this card instead.]]
	aux.EnableUnionAttribute(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE))
	--[[Each turn, the first time the equipped monster would be destroyed by battle or card effect, it is not destroyed.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:OPT()
	e3:SetValue(s.indesval)
	c:RegisterEffect(e3)
	--[[Your opponent's monsters cannot target for attacks, and your opponent cannot target with card effects, any monsters you control, except the equipped monster.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(aux.IsEquippedCond)
	e4:SetValue(s.tgtg)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(aux.IsEquippedCond)
	e5:SetTarget(s.tgtg)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
--E1
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(aux.AlreadyInRangeFilter(e,Card.IsPreviousLocation),1,nil,LOCATION_DECK)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end

--E3
function s.indesval(e,re,r,rp)
	return r&(REASON_BATTLE|REASON_EFFECT)~=0
end

--E4
function s.tgtg(e,c)
	return c~=e:GetHandler():GetEquipTarget()
end
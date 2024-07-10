--[[
Automatyrant Meteor Metal Claw
Automatiranno Artiglio Meteora di Metallo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is sent to the GY: You can Special Summon 1 "Automatyrant" monster from your hand, except "Automatyrant Meteor Metal Claw".]]
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
	--[[Once per turn, during damage calculation, if the equipped monster battles an opponent's monster: You can send the top 3 cards of your Deck to the GY;
	the equipped monster gains 800 ATK for each "Automatyrant" card sent to the GY this way, during that damage calculation only.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_SZONE)
	e3:OPT()
	e3:SetFunctions(s.atkcon,aux.DummyCost,s.atktg,s.atkop)
	c:RegisterEffect(e3)
	--[[If the equipped monster attacks a Defense Position monster, inflict piercing battle damage to your opponent.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
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
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	if not c or not c:IsRelateToBattle() then return false end
	local bc=c:GetBattleTarget()
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() and Duel.IsPlayerCanDiscardDeckAsCost(1-tp,3) end
	Duel.DiscardDeck(1-tp,3,REASON_COST)
	local og=Duel.GetGroupOperatedByThisCost(e):Filter(Card.IsSetCard,nil,ARCHE_AUTOMATYRANT):Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local ct=og:GetCount()
	Duel.SetTargetParam(ct)
	local c=e:GetHandler():GetEquipTarget()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation(),ct*800)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and ec:IsRelateToBattle() and ec:IsFaceup() then
		local val=Duel.GetTargetParam()*800
		ec:UpdateATK(val,RESET_PHASE|PHASE_DAMAGE_CAL,c)
	end
end
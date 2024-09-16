--[[
Dynastygian Soldier - "Sword"
Soldato Dinastigiano - "Spada"
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[All "Dynastygian" monsters you control gain 400 ATK/DEF for each "Dynastygian" monster you control.]]
	c:UpdateATKDEFField(
		aux.ForEach(s.cfilter,LOCATION_MZONE,0,nil,400),
		nil,
		LOCATION_MZONE,
		LOCATION_MZONE,
		0,
		aux.TargetBoolFunction(Card.IsSetCard,ARCHE_DYNASTYGIAN)
	)
	--[[If this card is Normal or Special Summoned, or if another "Dynastygian" monster(s) is Special Summoned to your field while you control this monster:
	You can Special Summon 1 "Dynastygian" monster from your hand or GY.]]
	local f=aux.ArchetypeFilter(ARCHE_DYNASTYGIAN)
	local sptg=xgl.SpecialSummonTarget(false,f,LOCATION_HAND|LOCATION_GRAVE)
	local spop=xgl.SpecialSummonOperation(false,f,LOCATION_HAND|LOCATION_GRAVE)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		nil,
		sptg,
		spop
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,0)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SHOPT()
	e3:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e3:SetFunctions(
		aux.AlreadyInRangeEventCondition(s.spcfilter),
		nil,
		sptg,
		spop
	)
	c:RegisterEffect(e3)
	--[[During your Main Phase: You can add 1 Level 4 "Dynastygian" monster from your Deck to your hand, except "Dynastygian Soldier - "Sword"",
	then, if your opponent controls more monsters than you do, you can Special Summon 1 Level 4 "Dynastygian" monster from your hand.]]
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(id,1)
	e4:SetCategory(CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:HOPT()
	e4:SetFunctions(
		nil,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e4)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DYNASTYGIAN)
end

--E3
function s.spcfilter(c,_,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(ARCHE_DYNASTYGIAN)
end

--E4
function s.thfilter(c)
	return c:IsLevel(4) and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0) and Duel.GetMZoneCount(tp)>0 then
		local sg=Duel.Group(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if #sg>0 and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
			Duel.ShuffleHand(tp)
			Duel.HintMessage(tp,HINTMSG_SPSUMMON)
			sg=sg:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
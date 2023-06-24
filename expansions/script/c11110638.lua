--Doomsday Artifice Eins
--Artificio del Giorno del Giudizio, Eins
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,s.lfilter,1,1)
	c:EnableReviveLimit()
	--[[If this card is Link Summoned: You can send 1 Psychic monster from your Deck to your GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.LinkSummonedCond)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	--[[During your Main Phase: You can target 1 DARK Psychic monster in your GY; Special Summon 1 "Doomsday Artifice" monster with a different Level from your Deck,
	but you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except Synchro Monsters.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.lfilter(c)
	return c:IsLinkAttribute(ATTRIBUTE_DARK) and c:IsLinkRace(RACE_PSYCHIC)
end

--FILTERS E1
function s.tgfilter(c)
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsAbleToGrave()
end
--E1
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

--FILTERS E2
function s.filter(c,e,tp)
	return c:IsMonster() and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_PSYCHIC) and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(ARCHE_DOOMSDAY_ARTIFICE) and c:HasLevel() and c:GetLevel()~=lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E2
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsInGY() and chkc:IsControler(tp) and s.filter(chkc,e,tp)
	end
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(true,s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 then
		local lv=tc:GetLevel()
		local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
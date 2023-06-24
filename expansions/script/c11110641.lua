--Gemini Fairy
--Fata Gemella
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_GEMINI),1,1)
	c:EnableReviveLimit()
	--[[If this card is Link Summoned: You can target 1 Gemini monster in your GY; Special Summon 1 Gemini monster from your Deck with the same Level as that monster,
	and if you do, it is treated as an Effect Monster and gains its effects.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.LinkSummonedCond)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.has_text_type=TYPE_GEMINI

--FILTERS E1
function s.filter(c,e,tp)
	return c:IsMonster(TYPE_GEMINI) and c:HasLevel() and Duel.IsExists(false,s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel())
end
function s.spfilter(c,e,tp,lv)
	return c:IsMonster(TYPE_GEMINI) and c:GetLevel()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E1
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
		local tc=g:GetFirst()
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			tc:EnableDualState()
		end
		Duel.SpecialSummonComplete()
	end
end
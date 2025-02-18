--[[
Nullfinite Tune
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your Main Phase, or when your opponent Special Summons a Synchro Monster (in which case this is a Quick Effect), while this card is banished (except during the Damage Step): You can
	shuffle this card and up to 2 other non-Tuner monsters from your banishment into the Deck, and if you do, Special Summon 1 DARK Fiend Synchro Monster from your Extra Deck, whose Level is equal to
	or lower than the combined Levels of all monsters shuffled into the Deck by this effect (this is treated as a Synchro Summon).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetLabelObject(aux.AddThisCardBanishedAlreadyCheck(c))
	e1a:SetCondition(aux.AlreadyInRangeEventCondition(s.cfilter))
	c:RegisterEffect(e1a)
	--[[If this card is banished, except from the Deck: You can target 1 card in your opponent's GY; banish it face-down.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetSendtoFunctions(LOCATION_REMOVED,TGCHECK_IT,aux.TRUE,0,LOCATION_GRAVE,1,1,nil,POS_FACEDOWN)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSummonPlayer(1-tp)
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER) and c:IsAbleToDeck()
end
function s.fselect(lv)
	return	function(g,e,tp,mg,c)
				Duel.SetSelectedCard(g)
				local res=g:CheckWithSumGreater(Card.GetLevel,lv)
				local ct=g:GetSum(Card.GetLevel)
				local _,min=g:GetMinGroup(Card.GetLevel)
				local razor={s.razorfilter,ct-min,lv}
				return res,false,razor
			end
end
function s.razorfilter(c,sum,lv)
	return not (c:GetLevel()+sum>=lv)
end
function s.spfilter(c,e,tp,mg,h)
	if not (c:IsType(TYPE_SYNCHRO) and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)) then
		return false
	end
	return xgl.SelectUnselectGroup(0,mg,e,tp,2,3,s.fselect(c:GetLevel()),0,nil,nil,nil,nil,nil,h)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,c)+c
	if chk==0 then
		return c:IsAbleToDeck() and #g>1 and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			and Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g,c)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,c)+c
	if #g<2 then return end
	local sc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g,c):GetFirst()
	if not sc then return end
	local lv=sc:GetLevel()
	local sg=xgl.SelectUnselectGroup(0,g,e,tp,2,3,s.fselect(lv),1,tp,HINTMSG_TODECK,s.fselect(lv),nil,nil,c)
	if Duel.Highlight(sg) and Duel.ShuffleIntoDeck(sg)>0 then
		if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
		sc:SetMaterial(nil)
		if Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
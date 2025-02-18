--[[
Nullfinite Circuit
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your Main Phase, or when your opponent Special Summons a Link Monster (in which case this is a Quick Effect), while this card is banished (except during the Damage Step): You can shuffle up to 4 of your banished monsters into the Deck, including this card, and if you do, Special Summon 1 DARK Fiend Link Monster from your Extra Deck, whose Link Rating is equal to the number
	of monsters shuffled into the Deck by this effect (this is treated as a Link Summon).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
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
	--[[If this card is banished, except from the Deck: You can banish 2 cards from your hand; draw 1 card.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(
		s.thcon,
		aux.BanishCost(nil,LOCATION_HAND,0,2),
		xgl.DrawTarget(0,1),
		xgl.DrawOperation()
	)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSummonPlayer(1-tp)
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.spfilter0(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false)
end
function s.spfilter1(c,e,tp,ct)
	if not s.spfilter0(c,e,tp) then
		return false
	end
	return c:GetLink()<=math.min(ct,4)
end
function s.spfilter2(c,ct)
	return c:GetLink()==ct
end
function s.fselect(sg)
	return	function(g,e,tp,mg,c)
				return sg:IsExists(s.spfilter2,1,nil,#g)
			end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then
		return g:IsContains(c) and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL)
			and Duel.IsExists(false,s.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,#g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	local sg=Duel.Group(s.spfilter0,tp,LOCATION_EXTRA,0,nil,e,tp)
	if not g:IsContains(c) or #sg==0 then return end
	local tg=xgl.SelectUnselectGroup(0,g,e,tp,1,4,s.fselect(sg),1,tp,HINTMSG_TODECK,s.fselect(sg),nil,nil,c)
	if Duel.Highlight(tg) and Duel.ShuffleIntoDeck(tg)>0 then
		local ct=Duel.GetGroupOperatedByThisEffect(e):FilterCount(Card.IsLocation,nil,LOCATION_DECK|LOCATION_EXTRA)
		if ct==0 or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_LMATERIAL) then return end
		sg=Duel.Group(s.spfilter0,tp,LOCATION_EXTRA,0,nil,e,tp)
		Duel.HintMessage(tp,HINTMSG_SPSUMMON)
	    local sc=sg:FilterSelect(tp,s.spfilter2,1,1,nil,ct):GetFirst()
		if not sc then return end
		sc:SetMaterial(nil)
		if Duel.SpecialSummon(sc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
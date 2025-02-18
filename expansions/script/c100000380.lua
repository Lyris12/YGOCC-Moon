--[[
Nullfinite Tribute
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,id)
	--[[During your Main Phase, or when your opponent Special Summons a Ritual Monster (in which case this is a Quick Effect), while this card is banished (except during the Damage Step): You can reveal 1 DARK Fiend Ritual Monster from
	your hand or Deck; shuffle your face-up banished monsters into the Deck whose total Levels equals or exceed the Level of that Ritual Monster, including this card, and if you do, Special Summon
	that revealed monster (this is treated as a Ritual Summon).]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TODECK)
	e1:SetCustomCategory(CATEGORY_SPSUMMON_RITUAL_MONSTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_REMOVED)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		aux.DummyCost,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	local e1a=e1:Clone()
	e1a:SetType(EFFECT_TYPE_QUICK_O)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetLabelObject(aux.AddThisCardBanishedAlreadyCheck(c))
	e1a:SetCondition(aux.AlreadyInRangeEventCondition(s.cfilter))
	c:RegisterEffect(e1a)
	--[[If this card is banished, except from the Deck: You can target 1 of your other face-up banished cards, except "Nullfinite Tribute"; add it to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetCondition(s.thcon)
	e2:SetSendtoFunctions(LOCATION_HAND,TGCHECK_IT,aux.FaceupFilter(aux.NOT(Card.IsCode),id),LOCATION_REMOVED,0,1,1,true)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c,_,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSummonPlayer(1-tp)
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
	local lv=c:GetLevel()
	return lv>0 and (not c:IsPublic() or not c:IsLocation(LOCATION_HAND)) and c:IsMonster(TYPE_RITUAL) and c:IsAttributeRace(ATTRIBUTE_DARK,RACE_FIEND)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
		and xgl.SelectUnselectGroup(0,mg,e,tp,1,#mg,s.fselect(lv),0,nil,nil,nil,nil,nil,h)
end
function s.gcheck(g,e,tp,mg,c)
	return g:IsExists(Card.IsCode,1,nil,CARD_VACUOUS_VASSAL) and Duel.GetMZoneCount(tp,g)>0
end
function s.tdfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsLevelAbove(1) and c:IsAbleToDeck()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then
		if not (e:IsCostChecked() and g:IsContains(c) and Duel.GetMZoneCount(tp)>0) then return false end
		return Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,g,c)
	end
	local tc=Duel.Select(HINTMSG_CONFIRM,false,tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,g,c):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.SetTargetCard(tc)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToChain() or not tc:IsRelateToChain() then return end
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if not g:IsContains(c) then return end
	local lv=tc:GetLevel()
	local sg=xgl.SelectUnselectGroup(0,g,e,tp,1,#g,s.fselect(lv),1,tp,HINTMSG_TODECK,s.fselect(lv),nil,nil,c)
	if Duel.Highlight(sg) and Duel.ShuffleIntoDeck(sg)>0 then
		tc:SetMaterial(nil)
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

--E2
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
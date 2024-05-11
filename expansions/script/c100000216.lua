--[[
Seer of Verdanse
Veggente di Verdanse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddCodeList(c,id,CARD_RUM_RITUAL_OF_VERDANSE)
	--[[If this card is Special Summoned: You can take 1 card from your Deck, and place it on the top of your Deck. If you control a DARK "Number" Xyz Monster,
	you can place 1 card from your Deck, GY, or banishment on the top of your Deck, instead.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--[[During the Main Phase, you can (Quick Effect): Immediately after this effect resolves, Xyz Summon 1 DARK "Number" Xyz Monster from your Extra Deck,
	by using monsters you control and "Verdanse" Ritual Monsters in your GY as material. If only your opponent controls a monster(s) that was Special Summoned from the Extra Deck,
	your opponent cannot activate cards or effects in response to this effect's activation.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		aux.MainPhaseCond(),
		nil,
		s.sptg,
		s.spop)
	c:RegisterEffect(e2)
	--[[A DARK "Number" Xyz Monster that has this card as material gains this effect.
	● Your opponent must play with their hand revealed, also their hand size limit becomes 3]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e3:SetCondition(s.effcon)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_HAND_LIMIT)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetCondition(s.effcon)
	e4:SetValue(3)
	c:RegisterEffect(e4)
end
--E1
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.tdfilter(c)
	return c:IsLocation(LOCATION_DECK) or c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetDeckCount(tp)>1
		or (Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExists(false,Card.IsAbleToDeck,tp,LOCATION_GB,0,1,nil))
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GB)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp,ce)
	local loc=Duel.IsExists(false,s.filter,tp,LOCATION_MZONE,0,1,nil) and LOCATION_DECK|LOCATION_GB or LOCATION_DECK
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,loc,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if tc:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,SEQ_DECKTOP)
	else
		Duel.HintSelection(g)
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end

--E2
function s.mfilter(c)
	return c:IsFaceupEx() and (not c:IsLocation(LOCATION_GRAVE) or (c:IsMonster(TYPE_RITUAL) and c:IsSetCard(ARCHE_VERDANSE)))
end
function s.xyzfilter(c,g)
	local mg=g:Filter(Card.IsCanBeXyzMaterial,nil,c)
	return c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsXyzSummonable(mg)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
		return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,g)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	local g=Duel.Group(Card.IsSummonLocation,tp,LOCATION_MZONE,LOCATION_MZONE,nil,LOCATION_EXTRA)
	if #g>0 and not g:IsExists(Card.IsControler,1,nil,tp) then
		Duel.SetChainLimit(s.chlimit)
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.Necro(s.mfilter),tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,g)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		if xyz then
			local mg=g:Filter(Card.IsCanBeXyzMaterial,nil,xyz)
			Duel.XyzSummon(tp,xyz,mg,1,#mg)
		end
	end
end

--E3
function s.effcon(e)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
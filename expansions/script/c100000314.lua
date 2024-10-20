--[[
Invernal of the War Drums
Invernale dei Tamburi da Guerra
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is in your hand: You can target 2 DARK and/or Reptile monsters in your GY; shuffle those targets into the Deck, and if you do, Special Summon this card,
	then send cards from the top of your Deck to the GY, up to the number of monsters your opponent controls +1.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_SPECIAL_SUMMON|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[Once per turn: You can declare a Level from 1 to 12; for the rest of this turn, the Levels of all DARK monsters you currently control become the declared Level.
	You cannot Special Summon monsters from your Extra Deck during the turn you activate the following effect, except DARK "Number" Xyz Monsters.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.SSRestrictionCost(s.cfilter,true,nil,id,LOCATION_EXTRA,3),
		s.lvtg,
		s.lvop
	)
	c:RegisterEffect(e2)
	
end

--E1
function s.tdfilter(c)
	return c:IsMonster() and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_REPTILE)) and c:IsAbleToDeck()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExists(true,s.tdfilter,tp,LOCATION_GRAVE,0,2,nil) and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsPlayerCanDiscardDeck(tp,1)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards():Filter(s.tdfilter,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			local dct=Duel.GetDeckCount(tp)
			if dct==0 then return end
			local ct=math.min(Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)+1,dct)
			if ct>1 then
				Duel.HintMessage(tp,aux.Stringid(id,1))
				ct=Duel.AnnounceNumberMinMax(tp,1,ct,s.ctchk)
			end
			Duel.BreakEffect()
			Duel.DiscardDeck(tp,ct,REASON_EFFECT)
		end
	end
end
function s.ctchk(i,tp)
	return Duel.IsPlayerCanDiscardDeck(tp,i)
end

--E2
function s.cfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.lvfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:HasLevel()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	local exclv={}
	for i=1,12 do
		if not g:IsExists(aux.NOT(Card.IsLevel),1,nil,i) then
			table.insert(exclv,i)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,12,table.unpack(exclv))
	Duel.SetTargetParam(lv)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=Duel.GetTargetParam()
	local g=Duel.Group(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		tc:ChangeLevel(lv,true,{c,true})
	end
end
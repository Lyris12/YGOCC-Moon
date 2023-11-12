--[[
Judgment of the Sky Mistress
Giudizio della Padrona del Cielo
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Reduce your Engaged monster's Level by any multiple of 2, then target the same number of monsters your opponent controls;
	negate their effects, then, if "Mistress of the Sky" is Engaged in your hand, or it is in your GY and/or among your face-up banished cards,
	you can send 1 "Sacred Effigy of Water" from your Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetCost(aux.DummyCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY: You can reveal 1 "The Embodiments of Movement" in your Extra Deck;
	add 1 "Sacred Effigy of Water" and 1 "Mistress of the Sky" from your GY to your hand, but you cannot Special Summon monsters with those same original names for the rest of this turn.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT(EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateMonsterFilter(chkc) end
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		return e:IsCostChecked() and en and en:IsMonster() and en:IsLevelAbove(3) and Duel.IsExists(true,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,2,nil)
	end
	local AvailableNums={}
	for i=2,en:GetLevel(),2 do
		if Duel.IsExists(true,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,i,nil) then
			table.insert(AvailableNums,i)
		else
			break
		end
	end
	if #AvailableNums==0 then return end
	Duel.HintMessage(tp,STRING_INPUT_LEVEL)
	local lv=Duel.AnnounceNumber(tp,table.unpack(AvailableNums))
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetCondition(aux.ResetIfNotEngaged(en:GetEngagedID()))
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	e1:SetValue(-lv)
	en:RegisterEffect(e1,true)
	Duel.AdjustInstantly(en)
	local tg=Duel.Select(HINTMSG_DISABLE,true,tp,aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,lv,lv,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,#tg,1-tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.filter(c)
	return c:IsFaceupEx() and c:IsCode(CARD_MISTRESS_OF_THE_SKY) and (not c:IsLocation(LOCATION_HAND) or c:IsEngaged())
end
function s.tgfilter(c)
	return c:IsCode(CARD_SACRED_EFFIGY_OF_WATER) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		local ok=false
		for tc in aux.Next(g) do
			local _,_,res=Duel.Negate(tc,e)
			if res then
				ok=true
			end
		end
		if ok and Duel.IsExists(false,s.filter,tp,LOCATION_HAND|LOCATION_GB,0,1,nil) then
			local mg=Duel.Group(s.tgfilter,tp,LOCATION_DECK,0,nil)
			if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.HintMessage(tp,HINTMSG_TOGRAVE)
				local sg=mg:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.BreakEffect()
					Duel.SendtoGrave(sg,REASON_EFFECT)
				end
			end
		end
	end
end

--E2
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,1,nil,CARD_THE_EMBODIMENTS_OF_MOVEMENTS) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_EXTRA,0,1,1,nil,CARD_THE_EMBODIMENTS_OF_MOVEMENTS)
	Duel.ConfirmCards(1-tp,g)
end
function s.filter1(c,tp,code)
	return c:IsCode(code) and c:IsAbleToHand()
		and (not tp or Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,c,nil,CARD_MISTRESS_OF_THE_SKY))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_GRAVE,0,1,nil,tp,CARD_SACRED_EFFIGY_OF_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
function s.plfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	
	local g1=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.filter1),tp,LOCATION_GRAVE,0,1,1,nil,tp,CARD_SACRED_EFFIGY_OF_WATER)
	if #g1==0 then return end
	local g2=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.filter1),tp,LOCATION_GRAVE,0,1,1,g1,nil,CARD_MISTRESS_OF_THE_SKY)
	if #g2==0 then return end
	g1:Merge(g2)
	if #g1==2 then
		Duel.Search(g1,tp)
	end
end
function s.sumlimit(e,c)
	return c:IsOriginalCodeRule(CARD_SACRED_EFFIGY_OF_WATER,CARD_MISTRESS_OF_THE_SKY)
end
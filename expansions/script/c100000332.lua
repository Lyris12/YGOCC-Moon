--[[
The Invocation of Arcarum - Iustitia
L'Invocazione dell'Arcarum - Iustitia
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,5,s.TLcon,s.TLmat,aux.TimeleapMaterialSendtoGrave())
	--Mentions
	aux.AddCodeList(c,CARD_SANCTUARY_SKY,CARD_THE_INVOCATION_OF_ARCANA,CARD_THE_INVOCATION_OF_JUSTICE)
	--[[If this Time Leap Summoned card you control is sent to the GY: You can target 1 card your opponent controls; send it to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetFunctions(
		s.tgcon,
		nil,
		xgl.SendtoTarget(LOCATION_GRAVE,TGCHECK_IT,nil,0,LOCATION_ONFIELD,1,1),
		xgl.SendtoOperation(LOCATION_GRAVE,TGCHECK_IT,nil,0,LOCATION_ONFIELD,1,1)
	)
	c:RegisterEffect(e1)
	--[[If this card is Time Leap Summoned: You can activate this effect; apply 1 of the following effects during your next Draw Phase, before your normal draw. If your opponent controls more cards
	than you do, apply 1 of the following effects when this effect resolves, instead.
	● Add 1 Level 4 Fairy monster, 1 "Arcarum" monster, 1 "The Invocation of Justice", or 1 card that mentions "The Sanctuary in the Sky" from your Deck to your hand.
	● Set 1 Counter Trap from your hand or GY. It can be activated this turn.
	● Send 1 card your opponent controls to the GY.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_LEAVE_GRAVE|CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetFunctions(
		aux.TimeleapSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
		local ge1=ge1:Clone()
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		Duel.RegisterEffect(ge1,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_CHAIN_DISABLED)
		Duel.RegisterEffect(ge3,0)
	end)
end
s.has_text_type = TYPE_COUNTER

function s.TLcon(e,c,tp)
    return Duel.PlayerHasFlagEffect(tp,id)
end
function s.TLmat(c,e,mg,tl,tp)
	return c:IsSetCard(ARCHE_THE_INVOCATION_OF) or c:IsAttributeRace(ATTRIBUTE_LIGHT,RACE_FAIRY)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.PlayerHasFlagEffect(rp,id) then
		local ecodechk=e:GetCode()==EVENT_CHAIN_SOLVED
		if ecodechk and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
			local code1,code2=Duel.GetChainInfo(Duel.GetCurrentChain(),CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
			if code1==CARD_THE_INVOCATION_OF_ARCANA or code2==CARD_THE_INVOCATION_OF_ARCANA then
				Duel.RegisterFlagEffect(rp,id,0,0,0)
			end
		elseif not ecodechk then
			Duel.RegisterFlagEffect(rp,id,0,0,0)
		end
	end
end

--E1
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_TIMELEAP) and c:IsPreviousControler(tp)
end

--E2
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b0=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD,0)
	local b1=s.bullet_1(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.bullet_2(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.bullet_3(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then
		return b0 or b1 or b2 or b3
	end
	local g=Duel.Group(Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetConditionalOperationInfo(not b0 and not b2 and not b3,0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetConditionalOperationInfo(not b0 and not b1 and not b3,0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetConditionalOperationInfo(not b0 and not b1 and not b2,0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD,0) then
		local rct=Duel.GetNextPhaseCount(PHASE_DRAW,tp)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:OPT()
		e1:SetCondition(aux.TurnPlayerCond(0))
		e1:SetOperation(s.applyop)
		e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,rct)
		Duel.RegisterEffect(e1,tp)
	else
		s.applyop(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local b1=s.bullet_1(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.bullet_2(e,tp,eg,ep,ev,re,r,rp,0)
	local b3=s.bullet_3(e,tp,eg,ep,ev,re,r,rp,0)
	if not b1 and not b2 and not b3 then return end
	if e:GetCode()==EVENT_PREDRAW then Duel.Hint(HINT_CARD,tp,id) end
	local opt=aux.Option(tp,nil,nil,{b1,STRING_ADD_TO_HAND},{b2,STRING_SET},{b3,STRING_SEND_TO_GY})
	if opt==0 then
		s.bullet_1(e,tp,eg,ep,ev,re,r,rp,1)
	elseif opt==1 then
		s.bullet_2(e,tp,eg,ep,ev,re,r,rp,1)
	elseif opt==2 then
		s.bullet_3(e,tp,eg,ep,ev,re,r,rp,1)
	end
end

--Bullet 1
function s.thfilter(c)
	return c:IsAbleToHand() and ((c:IsRace(RACE_FAIRY) and c:IsLevel(4)) or (c:IsMonster() and c:IsSetCard(ARCHE_ARCARUM)) or c:IsCode(CARD_THE_INVOCATION_OF_JUSTICE) or c:Mentions(CARD_SANCTUARY_SKY))
end
function s.bullet_1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--Bullet 2
function s.setfilter(c)
	return c:IsTrap(TYPE_COUNTER) and c:IsSSetable()
end
function s.bullet_2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.setfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil) end
	local g=Duel.Select(HINTMSG_SET,false,tp,aux.Necro(s.setfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SSetAndFastActivation(tp,g,e)
	end
end

--Bullet 3
function s.bullet_3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,Card.IsAbleToGrave,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
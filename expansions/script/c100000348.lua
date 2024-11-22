--[[
Manaseal Word - Finite
Parola Manasigillo - Finito
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--If you control a "Manaseal" monster, you can activate this card from your hand.
	c:TrapCanBeActivatedFromHand(s.handactcon,aux.Stringid(id,5))
	--[[Activate 1 of these effects.
	● Target 1 Spell your opponent controls or in their GY; shuffle it into the Deck, and if you do, your opponent cannot activate Spell Cards with that same type (Normal, Quick-Play, Equip, Ritual,
	Continuous, Field) until the next Standby Phase.
	● Return 3 of your face-down banished cards to the GY; for the next 2 turns after this effect resolves, Spell Cards and their effects can only be activated during the Main Phase 2, also neither
	player can activate Spell Cards or effects during their opponent's turn.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		aux.DummyCost,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If you control "Manaseal Rune Weaving" while this card is in your GY, apply the following effect.
	● Each time the activation or effect of a Spell Card or effect is negated, immediately inflict 100 damage to your opponent for each Spell on the field and in the GYs.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,6)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHAIN_DISABLED)
	c:RegisterEffect(e3)
end
function s.handactcon(e)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_MANASEAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--E1
function s.cfilter(c,e,tp)
	return c:IsFacedown() and c:IsAbleToReturnToGraveAsCost(e,tp)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.cfilter,tp,LOCATION_REMOVED,0,3,nil,e,tp) end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_REMOVED,0,3,3,nil,e,tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST|REASON_RETURN)
	end
end
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSpell() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD|LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.tdfilter(chkc) end
	local b1=Duel.IsExists(true,s.tdfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil)
	local b2=(not e:IsCostChecked() or s.cost2(e,tp,eg,ep,ev,re,r,rp,0))
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_TODECK)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		local g=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,1,nil)
		Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	elseif opt==1 then
		e:SetCategory(0)
		e:SetProperty(0)
		if e:IsCostChecked() then
			s.cost2(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=Duel.GetTargetParam()
	if opt==0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() then
			local typ=tc:GetType()&SUBTYPES_SPELL
			if Duel.ShuffleIntoDeck(tc)>0 then
				Debug.Message(typ)
				local rct=Duel.GetNextPhaseCount(PHASE_STANDBY)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_ACTIVATE)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetTargetRange(0,1)
				e1:SetLabel(typ)
				e1:SetValue(s.aclimit)
				e1:SetReset(RESET_PHASE|PHASE_STANDBY,rct)
				Duel.RegisterEffect(e1,tp)
				Duel.RegisterHint(1-tp,id,PHASE_STANDBY,rct,id,3)
			end
		end
	elseif opt==1 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetValue(s.aclimit2)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterHint(tp,id,PHASE_END,2,id,4)
		Duel.RegisterHint(1-tp,id,PHASE_END,2,id,4)
		aux.ManagePyroClockInteraction(c,tp,nil,PHASE_END,2,nil,nil,e1)
	end
end
function s.aclimit(e,re,tp)
	local typ=e:GetLabel()
	local rtyp=re:GetActiveType()
	return rtyp&TYPE_SPELL==TYPE_SPELL and ((typ==0 and rtyp==TYPE_SPELL) or (typ>0 and rtyp&typ==typ))
end
function s.aclimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL) and (not Duel.IsMainPhase(nil,2) or Duel.IsTurnPlayer(1-tp))
end

--E2
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),tp,LOCATION_ONFIELD,0,1,nil)
		and re:IsActiveType(TYPE_SPELL)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FaceupExFilter(Card.IsSpell),tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	if ct==0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Damage(1-tp,ct*100,REASON_EFFECT)
end
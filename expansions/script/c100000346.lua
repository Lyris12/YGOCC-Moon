--[[
Manaseal Word - Null
Parola Manasigillo - Nullo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--If you control a "Manaseal" monster, you can activate this card from your hand.
	c:TrapCanBeActivatedFromHand(s.handactcon,aux.Stringid(id,5))
	--[[Activate 1 of these effects.
	● Target 1 Spell in your opponent's GY; for the next 3 turns after this effect resolves, neither player can activate cards or effects with that same name.
	● Banish 3 "Manaseal" monsters from your GY, face-down; for the next 2 turns after this effect resolves, neither player can activate Spell Cards or effects, except "Rank-Up-Magic" or "Remnant"
	Spell Cards.]]
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
	● Each time the activation or effect of a Spell Card or effect is negated, all monsters your opponent controls immediately lose 200 ATK/400 DEF.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,6)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHAIN_DISABLED)
	c:RegisterEffect(e3)
end
function s.handactcon(e)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_MANASEAL),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--E1
function s.cfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_MANASEAL) and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsSpell() end
	local b1=Duel.IsExists(true,Card.IsSpell,tp,0,LOCATION_GRAVE,1,nil)
	local b2=not e:IsCostChecked() or s.cost2(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Select(HINTMSG_TARGET,true,tp,Card.IsSpell,tp,0,LOCATION_GRAVE,1,1,nil)
	elseif opt==1 then
		e:SetProperty(0)
		if e:IsCostChecked() then
			s.cost2(e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	local c=e:GetHandler()
	if opt==0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,1)
			e1:SetValue(s.aclimit)
			e1:SetLabel(tc:GetCode())
			e1:SetReset(RESET_PHASE|PHASE_END,3)
			Duel.RegisterEffect(e1,tp)
			Duel.RegisterHint(tp,id,PHASE_END,3,id,3)
			Duel.RegisterHint(1-tp,id,PHASE_END,3,id,3)
			aux.ManagePyroClockInteraction(c,tp,nil,PHASE_END,3,nil,nil,e1)
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
	return re:GetHandler():IsCode(e:GetLabel())
end
function s.aclimit2(e,re,tp)
	return re:IsActiveType(TYPE_SPELL) and not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsSetCard(ARCHE_REMNANT,ARCHE_RUM))
end

--E2
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),tp,LOCATION_ONFIELD,0,1,nil)
		and re:IsActiveType(TYPE_SPELL)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,tp,id)
	for tc in aux.Next(g) do
		tc:UpdateATKDEF(-200,-400,true,{c,true})
	end
end
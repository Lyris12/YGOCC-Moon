--[[
Dynastygian Listening Post
Postazione d'Ascolto Dinastigiana
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()

local FLAG_MUST_ACTIVATE = id+100

function s.initial_effect(c)
	--You can only control 1 "Dynastygian Listening Post".
	c:SetUniqueOnField(1,0,id)
	--[[When this card is activated: You can target 1 "Dynastygian" Normal Trap in your GY; Set it to your opponent's field. It can be activated this turn.]]
	local e0=c:Activation(true,true,nil,nil,s.target,s.activate,true)
	e0:SetDescription(id,0)
	c:RegisterEffect(e0)
	--[[Once per turn, during the Main Phase: You can target 1 "Number" Xyz Monster you control and a number of Set cards in your opponent's Spell & Trap Zones,
	up to the number of materials attached to that Xyz Monster; while this card is in your Spell & Trap Zone, that Set card(s) cannot be activated until the End Phase,
	and your opponent must activate it during the End Phase (if they cannot, they send it to the GY instead.). Your opponent cannot activate Set Spell/Trap Cards in response to
	this effect's activation.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:OPT()
	e2:SetRelevantTimings()
	e2:SetFunctions(
		aux.MainPhaseCond(),
		nil,
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e2)
	--[[During the Battle Phase, your opponent cannot activate cards or effects from the hand or GY.]]
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(aux.BattlePhaseCond())
	e3:SetValue(s.actlim)
	c:RegisterEffect(e3)
end
--E1
function s.setfilter(c,p)
	return c:IsNormalTrap() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsSSetable(false,p)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sefilter(chkc,1-tp) end
	if chk==0 then return true end
	if Duel.IsExists(true,s.setfilter,tp,LOCATION_GRAVE,0,1,nil,1-tp) and Duel.SelectYesNo(tp,STRING_ASK_SET) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.SetTargetParam(1)
		local g=Duel.Select(HINTMSG_SSET,true,tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil,1-tp)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,tp,0)
	else
		e:SetProperty(0)
		Duel.SetTargetParam(0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local param=Duel.GetTargetParam()
	if param==1 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsSSetable(false,1-tp) then
			Duel.SSetAndFastActivation(1-tp,tc,e)
		end
	end
end

--E2
function s.numfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:GetOverlayCount()>0
end
function s.fdfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExists(true,s.numfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExists(true,s.fdfilter,tp,0,LOCATION_SZONE,1,nil) end
	local numc=Duel.Select(HINTMSG_TARGET,true,tp,s.numfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	numc:RegisterFlagEffect(id,RESET_CHAIN,0,0)
	Duel.Select(HINTMSG_TARGET,true,tp,s.fdfilter,tp,0,LOCATION_SZONE,1,numc:GetOverlayCount(),nil)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,lp,tp)
	local c=e:GetHandler()
	return lp==tp or not (e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:IsActiveType(TYPE_TRAP) and c:IsOnField() and c:IsFacedown())
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsFaceup() then return end
	local g=Duel.GetTargetCards():Filter(aux.NOT(Card.HasFlagEffect),nil,id):Filter(Card.IsFacedown,nil)
	if #g>0 then
		local eid=e:GetFieldID()
		c:RegisterFlagEffect(FLAG_MUST_ACTIVATE,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,eid)
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(FLAG_MUST_ACTIVATE,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1,eid)
			c:SetCardTarget(tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetLabel(eid)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.rcon)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(id,2)
		e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE|PHASE_END)
		e2:SetLabel(eid)
		e2:SetCondition(s.actcon)
		e2:SetOperation(s.actop)
		Duel.RegisterEffect(e2,1-tp)
	end
end
function s.rcon(e)
	if Duel.IsEndPhase() then return false end
	local owner=e:GetOwner()
	local handler=e:GetHandler()
	return owner:IsHasCardTarget(handler) and owner:HasFlagEffectLabel(FLAG_MUST_ACTIVATE,e:GetLabel()) and handler:HasFlagEffectLabel(FLAG_MUST_ACTIVATE,e:GetLabel())
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local eid=e:GetLabel()
	local g=c:GetCardTarget()
	if not c:HasFlagEffectLabel(FLAG_MUST_ACTIVATE,eid) or not g or #g==0 or not g:IsExists(Card.HasFlagEffectLabel,1,nil,FLAG_MUST_ACTIVATE,eid) then
		e:Reset()
		return false
	end
	return true
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local eid=e:GetLabel()
	local g=c:GetCardTarget():Filter(Card.HasFlagEffectLabel,nil,FLAG_MUST_ACTIVATE,eid)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	local effect=tc:GetActivateEffect()
	if effect and effect:IsActivatable(tp) then
		Duel.Activate(effect)
	else
		Duel.Hint(HINT_CARD,tp,id)
		Duel.SendtoGrave(tc,REASON_RULE,PLAYER_NONE)
	end
	tc:GetFlagEffectWithSpecificLabel(FLAG_MUST_ACTIVATE,eid,true)
end

--E3
function s.actlim(e,re)
	local loc=re:GetActivateLocation()
	return loc&(LOCATION_HAND|LOCATION_GRAVE)>0
end
--[[
Automatyrant Integrator
Automatiranno Integratore
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When your opponent activates the effect of a monster they control (Quick Effect): You can discard this card, then target 1 "Automatyrant" monster you control;
	negate the activation, and if you do, equip that monster to that target as an Equip Spell with the following effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		s.condition,
		aux.DiscardSelfCost,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[If this card is sent to the GY: You can target 1 Machine monster you control and 1 Union monster in your GY;
	equip the second target to the first as if it were equipped by that second monster's effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.eqtg,s.eqop)
	c:RegisterEffect(e2)
end
s.has_text_type=TYPE_UNION

--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsActiveType(TYPE_MONSTER) or not Duel.IsChainNegatable(ev) then return false end
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	return p==1-tp and loc&LOCATION_MZONE>0
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AUTOMATYRANT)
end
function s.eqfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE) and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	local rc=re:GetHandler()
	local relation=rc:IsRelateToChain(ev)
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and (not relation or s.eqfilter(rc,tp))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if relation then
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,rc,1,rc:GetControler(),rc:GetLocation())
	else
		Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,0,0,rc:GetPreviousLocation())
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local rc=re:GetHandler()
		local tc=Duel.GetFirstTarget()
		if rc:IsRelateToChain(ev) and tc:IsRelateToChain() and s.filter(tc) and tc:IsControler(tp) and Duel.EquipToOtherCardAndRegisterLimit(e,tp,rc,tc) then
			local c=e:GetHandler()
			--The equipped monster gains ATK equal to this card's ATK.
			local e2=Effect.CreateEffect(rc)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(s.atkval)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			rc:RegisterEffect(e2)
			--If the equipped monster would be destroyed by battle or card effect, destroy this card instead.
			local e3=Effect.CreateEffect(rc)
			e3:SetType(EFFECT_TYPE_EQUIP)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
			e3:SetValue(s.desrepval)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			rc:RegisterEffect(e3)
		end
	end
end
function s.atkval(e,c)
	local val=e:GetHandler():GetAttack()
	return val>0 and val or 0
end
function s.desrepval(e,re,r,rp)
	return r&(REASON_BATTLE|REASON_EFFECT)~=0
end

--E2
function s.eqtofilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and Duel.IsExistingTarget(s.unionfilter,tp,LOCATION_GRAVE,0,1,c,c,tp)
end
function s.unionfilter(c,tc,tp)
	return aux.CheckUnionEquip(c,tc) and c:CheckUnionTarget(tc) and c:IsType(TYPE_UNION) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.eqtofilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc1=Duel.SelectTarget(tp,s.eqtofilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	tc1:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g2=Duel.SelectTarget(tp,s.unionfilter,tp,LOCATION_GRAVE,0,1,1,tc1,tc1,tp)
	Duel.SetCardOperationInfo(g2,CATEGORY_EQUIP)
	Duel.SetCardOperationInfo(g2,CATEGORY_LEAVE_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g~=2 then return end
	local tc1,tc2=g:GetFirst(),g:GetNext()
	if not tc1:HasFlagEffect(id) then
		if not tc2:HasFlagEffect(id) then
			return
		else
			tc1,tc2=tc2,tc1
		end
	end
	if s.unionfilter(tc2,tc1,tp) and Duel.Equip(tp,tc2,tc1) then
		aux.SetUnionState(tc2)
	end
end
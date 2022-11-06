--Pozione del Guaritore
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only activate 1 "Healer's Potion" per Duel.
● You can only use the ② effect of "Healer's Potion" once per turn.

① Gain 1000 LP for each time you took battle damage during this Duel (max. 8000).
② You can discard this card, then target 1 face-up monster on the field; it gains 1000 DEF, also it gains these effects.
● If this card would be destroyed by battle, it loses ATK equal to the exact difference between its DEF and the ATK of the monster that it battled, instead.
● When this card would be destroyed by a card effect, it loses exactly 1000 DEF instead.
● If the ATK of this card is 0, send it to the GY.
]]

function s.initial_effect(c)	
	Duel.EnableGlobalFlag(GLOBALFLAG_SELF_TOGRAVE)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.reccon)
	e1:SetTarget(s.rectg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	--HP Mechanic
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(aux.DiscardSelfCost)
	e2:SetTarget(aux.Target(aux.Faceup(Card.IsMonster),LOCATION_MZONE,nil,1))
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--Register Battle Damage
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(ep,id,0,0,1)
end

function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetFlagEffect(tp,id)
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.min(ct*1000,8000))
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetFlagEffect(tp,id)
	Duel.Recover(p,math.min(ct*1000,8000),REASON_EFFECT)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:UpdateDefense(1000,nil,c)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		--self destroy
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_SELF_TOGRAVE)
		e1:SetCondition(s.sdcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--destroy replace
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_DESTROY_REPLACE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTarget(s.desreptg)
		e2:SetOperation(s.desrepop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		--
		if not tc:IsType(TYPE_EFFECT) then
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_ADD_TYPE)
			e3:SetValue(TYPE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3,true)
		end
	end
end
function s.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x12d)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local b1=(c:IsOnField() and c:IsFaceup() and c:IsReason(REASON_BATTLE) and c:HasDefense() and c:HasAttack() and bc and bc:IsOnField() and bc:IsFaceup() and bc:HasAttack() and c:GetAttack()>=math.abs(bc:GetAttack()-c:GetDefense()))
	local b2=(c:IsOnField() and c:IsFaceup() and c:IsReason(REASON_EFFECT) and c:GetDefense()>=1000)
	if chk==0 then return b1 or b2 end
	if b1 then
		e:SetLabel(0)
		return true
	elseif b2 then
		e:SetLabel(1)
		return true
	else
		return false
	end
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		local bc=c:GetBattleTarget()
		c:UpdateATK(-math.abs(bc:GetAttack()-c:GetDefense()),true)
	elseif e:GetLabel()==1 then
		c:UpdateDEF(-1000,true)
	end
end
function s.sdcon(e)
	return e:GetHandler():IsAttack(0)
end
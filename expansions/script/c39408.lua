--Dracosis Gallanth
local s,id=GetID()
function s.initial_effect(c)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT(true)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	--dam
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	if not aux.DracosisTriggeringSetcodeCheck then
		aux.DracosisTriggeringSetcodeCheck=true
		aux.DracosisTriggeringSetcode={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	local rc=re:GetHandler()
	if rc:IsRelateToChain(ev) then
		if rc:IsSetCard(0x300) then
			aux.DracosisTriggeringSetcode[cid]=true
			return
		end
	else
		if rc:IsPreviousSetCard(0x300) then
			aux.DracosisTriggeringSetcode[cid]=true
			return
		end
	end
	aux.DracosisTriggeringSetcode[cid]=false
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	if re:IsActivated() then
		local ch=Duel.GetCurrentChain()
		local cid=Duel.GetChainInfo(ch,CHAININFO_CHAIN_ID)
		return aux.DracosisTriggeringSetcode[cid]==true
		
	elseif re:IsHasCustomCategory(nil,CATEGORY_FLAG_DELAYED_RESOLUTION) and re:IsHasCheatCode(CHEATCODE_SET_CHAIN_ID) then
		local cid=re:GetCheatCodeValue(CHEATCODE_SET_CHAIN_ID)
		return aux.DracosisTriggeringSetcode[cid]==true
		
	else
		return rc:IsSetCard(0x300)
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroup(tp,0,LOCATION_HAND):FilterCount(Card.IsDiscardable,nil,REASON_EFFECT)<=0 then return end
	local p=Duel.GetTurnPlayer()
	Duel.LoseLP(p,500)
	Duel.LoseLP(1-p,500)
	Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
end

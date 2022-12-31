--Shadowflame Medium
--Design and code by Kindrindra
local ref=_G['c'..28915257]
function ref.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--Counter
	if not c28915257.global_check then
		c28915257.global_check=true
		c28915257[0]=0
		c28915257[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		ge1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge1:SetOperation(ref.resetcount)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_CHAINING)
		ge2:SetCondition(ref.regcon)
		ge2:SetOperation(ref.regop)
		Duel.RegisterEffect(ge2,tp)
	end
	--banish
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetTarget(ref.rmtg)
	e4:SetOperation(ref.rmop)
	c:RegisterEffect(e4)
end

function ref.resetcount(e,tp,eg,ep,ev,re,r,rp)
	c28915257[2]=c28915257[Duel.GetTurnPlayer()]
	--print("Turn Player: ")
	--print(c28915257[2])
	
	c28915257[Duel.GetTurnPlayer()]=0
	c28915257[1-Duel.GetTurnPlayer()]=0
end
function ref.regcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsSetCard(0x729) and not re:GetHandler():IsCode(28915257)
end
function ref.regop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	c28915257[1-p]=c28915257[1-p]+1
	--print(c28915257[1-p])
end
--[[function ref.regop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		local p=tc:GetReasonPlayer()
		if Duel.GetTurnPlayer()~=p then
			c28915257[p]=c28915257[p]+1
		end
		tc=eg:GetNext()
	end
end]]

function ref.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=c28915257[2]
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToRemove() end
	if chk==0 then return (ct>0) and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function ref.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

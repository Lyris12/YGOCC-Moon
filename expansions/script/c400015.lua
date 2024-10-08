--Untergang ~~~
function c400015.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,400015+EFFECT_COUNT_CODE_OATH)
	e1:SetLabel(0)
	e1:SetCondition(c400015.condition)
	e1:SetTarget(c400015.target)
	e1:SetOperation(c400015.activate)
	c:RegisterEffect(e1)
	--pre-act
	if not c400015.global_check then
		c400015.global_check=true
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_CHAIN_SOLVED)
		e0:SetOperation(c400015.prop)
		e0:SetLabelObject(e1)
		Duel.RegisterEffect(e0,0)
		local re0=Effect.CreateEffect(c)
		re0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		re0:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		re0:SetOperation(function() e1:SetLabel(0) end)
		Duel.RegisterEffect(re0,0)
	end
end

--
function c400015.prop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsType(TYPE_QUICKPLAY) and rc:IsSetCard(0x246) then
		e:GetLabelObject():SetLabel(ct+1)
	end
end

function c400015.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x246)
end
function c400015.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function c400015.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local g=Duel.GetOperatedGroup()
		c:RegisterFlagEffect(400015,RESET_EVENT+0x1600000+RESET_PHASE+PHASE_END,0,1)
		--EP discard
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCondition(c400015.descon)
		e2:SetOperation(c400015.desop)
		g:KeepAlive()
		e2:SetLabelObject(g)
		Duel.RegisterEffect(e2,tp)
	end
end
function c400015.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(400015)~=0
end
function c400015.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g or (g and g:GetCount()==0) then return end
	if g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)==0 then return end
	g:Remove(Card.IsType,nil,TYPE_SPELL)
	Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	g:DeleteGroup()
end

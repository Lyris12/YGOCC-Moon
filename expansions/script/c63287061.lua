--created by Pina, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL+EFFECT_COUNT_CODE_OATH)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		s[2]=0
		s[3]=0
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_ADJUST)
		e5:SetOperation(s.count)
		Duel.RegisterEffect(e5,0)
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_RECOVER)
		e0:SetOperation(function(e,tp,eg,ep,ev) s[ep]=s[ep]+ev end)
		Duel.RegisterEffect(e0,0)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DESTROYED)
		e2:SetOperation(s.checkop)
		Duel.RegisterEffect(e2,0)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsReason(REASON_BATTLE+REASON_EFFECT) then
			if tc:IsPreviousControler(0) and tc:GetReasonPlayer()~=0 then p1=true end
			if tc:IsPreviousControler(1) and tc:GetReasonPlayer()~=1 then p2=true end
		end
		tc=eg:GetNext()
	end
	if p1 then Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1) end
	if p2 then Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1) end
end
function s.count(e,tp,eg,ep,ev,re,r,rp)
	local plp,clp,trn=e:GetLabel(),math.abs(Duel.GetLP(0)-Duel.GetLP(1)),Duel.GetTurnCount()
	if trn~=s[3] then s[2]=clp>=5000 and 1 or 0 s[3]=trn end
	e:SetLabel(clp)
	if plp==clp then return end
	if clp>=5000 then s[2][trn]=s[2][trn]+1 end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN2 and ((math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))>=5000 or s[2]>0) and s[tp]==0 or Duel.GetFlagEffect(tp,id)>4 or Duel.GetTurnCount()>10)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if math.abs(Duel.GetLP(tp)-Duel.GetLP(1-tp))<5000 and s[2]==0 or s[tp]>0 then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

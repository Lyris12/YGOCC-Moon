--Guardian-Summon Reflector Carbuncle
function c249000650.initial_effect(c)
	c:SetUniqueOnField(1,0,249000650)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--to grave
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c249000650.regop)
	c:RegisterEffect(e2)
	--reflect targeted effect reg
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,2490006501)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetTarget(c249000650.target)
	e3:SetOperation(c249000650.operation)
	c:RegisterEffect(e3)
	--change battle target
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54912977,0))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_BATTLE_CONFIRM)
	e4:SetCountLimit(1,2490006502)
	e4:SetCondition(c249000650.condition)
	e4:SetTarget(c249000650.target2)
	e4:SetOperation(c249000650.operation2)
	c:RegisterEffect(e4)
end
function c249000650.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(249000650,0))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DRAW)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1,2490006503)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c249000650.drtg)
		e1:SetOperation(c249000650.drop)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
function c249000650.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249000650.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c249000650.tgfilter(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
function c249000650.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000650.tgfilter,tp,LOCATION_MZONE,0,1,nil,e) end
end
function c249000650.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249000650.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVING)
			e1:SetRange(LOCATION_MZONE)
			e1:SetOperation(c249000650.disop)
			e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
function c249000650.filter(c,re,rp,tf,ceg,cep,cev,cre,cr,crp)
	return tf(re,rp,ceg,cep,cev,cre,cr,crp,0,c)
end
function c249000650.disop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsContains(e:GetHandler()) or tg:GetCount()~=1 then return false end
	local tf=re:GetTarget()
	if not tf then return end
	local res,ceg,cep,cev,cre,cr,crp=Duel.CheckEvent(re:GetCode(),true)
	if not Duel.IsExistingMatchingCard(c249000650.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),re,rp,tf,ceg,cep,cev,cre,cr,crp) 
		or not Duel.IsChainDisablable(ev) then return end
	local option
	if Duel.IsExistingMatchingCard(c249000650.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),re,rp,tf,ceg,cep,cev,cre,cr,crp)  then option=0 end
	if Duel.IsChainDisablable(ev) then option=1 end
	if Duel.IsExistingMatchingCard(c249000650.filter,tp,LOCATION_MZONE,LOCATION_ONFIELD,1,e:GetHandler(),re,rp,tf,ceg,cep,cev,cre,cr,crp)
		and Duel.IsChainDisablable(ev) then
		option=Duel.SelectOption(tp,aux.Stringid(21501505,0),1131)
	end
	if option==0 then
		Duel.ChangeTargetCard(ev,Duel.SelectMatchingCard(tp,c249000650.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),re,rp,tf,ceg,cep,cev,cre,cr,crp))
	else
		Duel.NegateEffect(ev)
	end
end
function c249000650.condition(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_REPLACE and Duel.GetAttackTarget()==e:GetHandler() and Duel.GetAttacker():IsControler(1-tp)
end
function c249000650.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,Duel.GetAttacker())
end
function c249000650.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local a=Duel.GetAttacker()
	if tc and tc:IsRelateToEffect(e)
		and a:IsAttackable() and not a:IsImmuneToEffect(e) then
		Duel.CalculateDamage(a,tc)
	end
end
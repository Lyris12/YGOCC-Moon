--created by Swag, coded by XGlitchy30
--Dreary Forest, Dreaming Heart
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableCounterPermit(COUNTER_SORROW)
	c:Activate()
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TRANSFORMED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(aux.PreTransformationCheckSuccess)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	aux.AddPreTransformationCheck(c,e1,s.tfcon)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(aux.AND(aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1),aux.TurnPlayerCond(1)))
	e2:SetValue(s.statval)
	c:RegisterEffect(e2)
	local e2x=e2:UpdateDefenseClone(c)
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,RELEVANT_TIMINGS)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.TurnPlayerCond(1))
	e3:SetCost(aux.BanishCost(aux.ArchetypeFilter(ARCHE_DREARY_FOREST),LOCATION_GRAVE,0,1))
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsCanAddCounter(COUNTER_SORROW,1) then
		c:AddCounter(COUNTER_SORROW,1)
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_DREARY_FOREST)
end
function s.statval(e,c)
	local ct=e:GetHandler():GetCounter(COUNTER_SORROW)
	if ct<0 then ct=0 end
	return -ct*100
end
function s.filter(c,arche,e,tp)
	if not (c:IsFaceup() and c:IsSetCard(arche) and c:IsLevelAbove(3)) then return false end
	if arche&ARCHE_DREAMY_FOREST==ARCHE_DREAMY_FOREST then
		side=SIDE_REVERSE
	end
	if arche&ARCHE_DREARY_FOREST==ARCHE_DREARY_FOREST then
		side=side|SIDE_OBVERSE
	end
	return c:IsCanTransform(side,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()<0 then return false end
		local arche = e:GetLabel()==0 and ARCHE_DREAMY_FOREST or e:GetLabel()==1 and ARCHE_DREARY_FOREST or 0
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,arche,e,tp)
	end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,ARCHE_DREAMY_FOREST|ARCHE_DREARY_FOREST,e,tp) end
	local g=Duel.Select(HINTMSG_TRANSFORM,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,ARCHE_DREAMY_FOREST|ARCHE_DREARY_FOREST,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		local b1=tc:IsSetCard(ARCHE_DREAMY_FOREST) and tc:IsCanTransform(SIDE_REVERSE,e,tp)
		local b2=tc:IsSetCard(ARCHE_DREARY_FOREST) and tc:IsCanTransform(SIDE_OBVERSE,e,tp)
		local opt=aux.Option(tp,id,2,b1,b2)
		e:SetLabel(opt)
	else
		e:SetLabel(-1)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local lab=e:GetLabel()
	if lab<0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		local side = lab==0 and SIDE_REVERSE or lab==1 and SIDE_OBVERSE
		Duel.Transform(tc,side,e,tp)
	end
end
function s.tffilter(c,tp,re)
	return c:IsFaceup() and c:IsOnField() and c:IsControler(tp) and c:IsSetCard(ARCHE_DREAMY_FOREST,ARCHE_DREARY_FOREST) and re:GetHandler()==c
end
function s.tfcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return r&REASON_EFFECT~=0 and eg:IsExists(s.tffilter,1,nil,tp,re)
end

--Piromane Deltaingranaggi
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(aux.CreateCost(aux.SSLimit(s.limfilter,1,true,nil,id,s.counterfilter),aux.ToDeckSelfCost))
	e1:SetTarget(aux.SSTarget(s.spfilter,LOCATION_DECK,0,1))
	e1:SetOperation(aux.SSOperation(s.spfilter,LOCATION_DECK,0,1))
	c:RegisterEffect(e1)
	--place counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(aux.MainPhaseCond(0))
	e2:SetTarget(s.cttg)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	--check for counter before the cards leave the field
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3x:SetCode(EVENT_LEAVE_FIELD_P)
	e3x:SetRange(LOCATION_MZONE)
	e3x:SetLabel(0)
	e3x:SetOperation(s.damp)
	c:RegisterEffect(e3x)
	--group monsters that left the field
	local g=Group.CreateGroup()
	g:KeepAlive()
	local e3y=Effect.CreateEffect(c)
	e3y:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3y:SetCode(EVENT_LEAVE_FIELD)
	e3y:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3y:SetRange(LOCATION_MZONE)
	e3y:SetOperation(s.regop)
	--inflict damage by counting all grouped monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabel(0)
	e3:SetLabelObject(g)
	e3:HOPT()
	e3:SetTarget(s.damtg)
	e3:SetOperation(aux.DamageOperation())
	c:RegisterEffect(e3)
	--complete e3 registration
	e3y:SetLabelObject(e3)
	c:RegisterEffect(e3y)
end
function s.counterfilter(c)
	return c:IsSetCard(0xfa6) or not c:IsSummonLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function s.limfilter(c)
	return c:IsSetCard(0xfa6) or not c:IsLocation(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spfilter(c)
	return c:IsSetCard(0xfa6) and c:IsLevelAbove(7)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Filter(Card.IsFaceup,nil)
	for tc in aux.Next(g) do
		if tc:IsCanAddCounter(0x1fa6,1) then
			tc:AddCounter(0x1fa6,1)
		end
	end
end

function s.dpfilter(c,tp)
	return c:IsControler(1-tp) and c:GetCounter(0x1fa6)>0
end
function s.damp(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.dpfilter,nil,tp)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_CHAIN,0,1,tc:GetCounter(0x1fa6))
	end
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	local c=e:GetHandler()
	local tg=eg:Filter(Card.HasFlagEffect,nil,id)
	if #tg>0 then
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id+100,RESET_CHAIN,0,1)
		end
		local ch=Duel.GetCurrentChain()
		local ct=e:GetLabelObject():GetLabel()
		local g=e:GetLabelObject():GetLabelObject()
		if ch==0 then
			ct=0
			g:Clear()
		end
		g:Merge(tg)
		for tc in aux.Next(g) do
			if not tc:HasFlagEffect(id+100) then
				g:RemoveCard(tc)
				ct=ct-1
			elseif tc:HasFlagEffect(id) then
				ct=ct+tc:GetFlagEffectLabel(id)
				tc:ResetFlagEffect(id)
			end
		end
		e:GetLabelObject():SetLabel(ct)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local ct=e:GetLabel()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct*300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
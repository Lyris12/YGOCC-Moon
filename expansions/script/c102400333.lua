--created & coded by Lyris
--リージル・リターン
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,aux.FilterBoolFunction(Card.IsSetCard,0xaaa))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsSetCard),0xaaa))
	Duel.RegisterEffect(e1,tp)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xaaa) and not c:IsControler(c:GetOwner())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,LOCATION_MZONE,nil,0xaaa)
	local tg=Group.CreateGroup()
	for tc in aux.Next(g) do if not tc:IsImmuneToEffect(e) and tc:GetFlagEffect(id)==0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		tg:AddCard(tc)
	end end
	tg:KeepAlive()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetEqualFunction(Card.GetFlagEffect,1,id))
	e1:SetLabelObject(tg)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetLabelObject(e1)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetLabelObject(e2)
	e3:SetLabel(Duel.GetChainInfo(0,CHAININFO_CHAIN_ID))
	e3:SetOperation(s.reset)
	Duel.RegisterEffect(e3,tp)
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)==e:GetLabel() then
		local e2=e:GetLabelObject()
		local e1=e2:GetLabelObject()
		local tg=e1:GetLabelObject()
		for tc in aux.Next(tg) do
			tc:ResetFlagEffect(id)
		end
		tg:DeleteGroup()
		e1:Reset()
		e2:Reset()
		e:Reset()
	end
end

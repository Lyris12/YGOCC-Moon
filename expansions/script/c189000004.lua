--created by Moon Burst, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,3,3,aux.gcheck)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(1166)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(SUMMON_TYPE_LINK)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.operation)
	c:RegisterEffect(e0)
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	e3:SetValue(aux.linklimit)
	c:RegisterEffect(e3)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
	e3:SetValue(id-3)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsCode(id-4) end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
function s.matfilter(c,codes)
	return codes[Card.GetLinkCode()] and c:IsAbleToDeckAsCost()
end
function s.condition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local t={[id-3]=true,[id+2]=true,[id+6]=true}
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,t)
	return g:GetClassCount(Card.GetLinkCode)>2 and Duel.GetLocationCountFromEx(tp)>0
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,c)
	local t={[id-3]=true,[id+2]=true,[id+6]=true}
	local g,mg,g1,mc=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,t),Group.CreateGroup()
	for i=0,2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		g1=g:FilterSelect(tp,Card.IsLinkCode,1,1,nil,table.unpack(t))
		mg:Merge(g1)
		mc=g1:GetFirst()
		t[mc:GetLinkCode()]=nil
	end
	Duel.SendtoDeck(mg,nil,2,REASON_COST)
end
function s.filter(c,e,tp,ec)
	return c:IsType(TYPE_UNION) and c:IsSetCard(0x191) and c:IsCanBeEffectTarget(e) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(ec) and aux.CheckUnionEquip(ec,c)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp,e:GetHandler()) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,e:GetHandler()) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g,mg,g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,0,nil,e,tp,e:GetHandler()),Group.CreateGroup()
	repeat
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		mg=mg+g1
		ft=ft-1
	until ft==0 or #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0))
	Duel.SetTargetCard(mg)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,mg,#mg,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if ft<#g then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local tc=g:GetFirst()
	while tc do
		if aux.CheckUnionEquip(c,tc)
			and Duel.Equip(tp,tc,c,true,true) then
			aux.SetUnionState(tc)
		end
		tc=g:GetNext()
	end
	Duel.EquipComplete()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp then return false end
	return e:GetHandler():IsRelateToBattle()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(Card.IsHasEffect,nil,EFFECT_UNION_STATUS)
	Duel.Destroy(g,REASON_EFFECT)
end

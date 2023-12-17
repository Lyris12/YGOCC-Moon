--Winter Spirit Jack
--  Idea: Alastar Rainford
--  Script: Shad3
--  Editor: Keddy, XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--CounterAdd
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.a_op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c)
	--Register when it was placed on the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_NO_TURN_RESET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_ADJUST)
	e4:SetCountLimit(1)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	--Check for how long it has been on the field
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_TURN_END)
	e5:OPT()
	e5:SetOperation(s.regop)
	c:RegisterEffect(e5)
	--Remember flag
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetCode(EVENT_LEAVE_FIELD_P)
	e6:SetOperation(s.rememberop)
	c:RegisterEffect(e6)
	--Counter
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_COUNTER)
	e7:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_LEAVE_FIELD)
	e7:SetTarget(s.d_tg)
	e7:SetOperation(s.d_op)
	c:RegisterEffect(e7)
	e6:SetLabelObject(e7)
end

function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	local check=false
	for tc in aux.Next(eg) do
		if tc:IsFaceup() and tc:IsControler(1-tp) and tc:IsCanAddCounter(COUNTER_ICE,1) then
			if not check then
				check=true
				Duel.Hint(HINT_CARD,tp,id)
			end
			tc:AddCounter(COUNTER_ICE,1)
		end
	end
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:HasFlagEffect(id) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,1)
	else
		c:UpdateFlagEffectLabel(id)
	end
	c:SetHint(CHINT_NUMBER,c:GetFlagEffectLabel(id))
end

function s.rememberop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetFlagEffectLabel(id)
	if not ct then ct=0 end
	e:GetLabelObject():SetLabel(ct)
end

function s.ctfilter(c,ct)
	return c:IsFaceup() and (ct==0 or c:IsCanAddCounter(COUNTER_ICE,ct))
end
function s.d_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	if not ct then ct=0 end
	Duel.SetTargetParam(ct)
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,COUNTER_ICE,ct)
end
function s.d_op(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	if ct==0 then return end
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil,ct)
	if g:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local sg=g:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		sg:GetFirst():AddCounter(COUNTER_ICE,ct)
	end
end
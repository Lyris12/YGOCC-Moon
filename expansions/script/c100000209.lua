--[[
Eternadir Scout Esom
Esploratore Eternadir Esom
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--If you control no monsters, or all monsters you control are "Eternadir" monsters, you can Normal Summon this card without Tributing.
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SUMMON_PROC)
	e0:SetCondition(s.ntcon)
	c:RegisterEffect(e0)
	--If this card is Pendulum Summoned: You can negate the effects of all face-up cards your opponent currently controls.
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(aux.PendulumSummonedCond,nil,s.distg,s.disop)
	c:RegisterEffect(e1)
	--If your "Eternadir" monster would Tribute exactly 1 monster to activate its effect, you can banish this card from your GY instead.
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(CARD_ETERNADIR_SCOUT_ESOM)
	e2:HOPT()
	c:RegisterEffect(e2)
end

--E0
function s.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(ARCHE_ETERNADIR)
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil))
end

--E1
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,1-tp,LOCATION_ONFIELD)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	for tc in aux.Next(g) do
		Duel.Negate(tc,e,0,false,false,TYPE_NEGATE_ALL)
	end
end
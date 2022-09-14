--Iperdrive Arbitratrice
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--engage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SHOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--increase energy
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SHOPT()
	e2:SetCondition(aux.MainOrBattlePhaseCond())
	e2:SetCost(s.encost)
	e2:SetTarget(s.entg)
	e2:SetOperation(s.enop)
	c:RegisterEffect(e2)
end
function s.filter(c,tp,ign)
	return c:IsMonster(TYPE_DRIVE) and c:IsCanEngage(tp,ign)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		return en~=nil and en:IsDiscardable(REASON_EFFECT) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,en,tp,true)
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,en,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if en and Duel.SendtoGrave(en,REASON_EFFECT+REASON_DISCARD)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,tp)
		if #g>0 then
			g:GetFirst():Engage(e,tp)
		end
	end
end

function s.cfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost() and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function s.encost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,e:GetHandler())
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		return en~=nil and en:IsCanUpdateEnergy(2,tp,REASON_EFFECT)
	end
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard(tp)
	if en then
		en:UpdateEnergy(2,tp,REASON_EFFECT,0,c)
	end
end
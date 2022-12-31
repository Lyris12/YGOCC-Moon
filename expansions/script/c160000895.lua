--Yokaidy Kitsune Beibu
-- Keddy was here.
function c160000895.initial_effect(c)

	  --special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
   -- e1:SetCountLimit(1,160000895)
	e1:SetCondition(c160000895.spcon)
	c:RegisterEffect(e1) 
   --atk up
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41209827,0))
	e2:SetCategory(CATEGORY_COUNTER+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,160000895)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c160000895.actg)
	e2:SetOperation(c160000895.acop)
	c:RegisterEffect(e2)
 --search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(160000895,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,160000896)
	e3:SetTarget(c160000895.target)
	e3:SetOperation(c160000895.operation)
	c:RegisterEffect(e3)
 
end
function c160000895.spfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c160000895.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and not Duel.IsExistingMatchingCard(c160000895.spfilter,tp,0,LOCATION_MZONE,1,nil)
end
function c160000895.kafilter(c)
	return c:IsFaceup() and not c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c160000895.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c160000895.acop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(c160000895.kafilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1241,1)
		 --atk down
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e3:SetCondition(c160000895.discon)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		e3:SetValue(ATTRIBUTE_LIGHT)
		tc:RegisterEffect(e3)
		--atk down
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_CHANGE_RACE)
		e4:SetCondition(c160000895.discon)
		e4:SetValue(RACE_FIEND)
		e4:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e4)
		tc=g:GetNext()
	end
	Duel.Draw(p,d,REASON_EFFECT)
end

function c160000895.discon(e)
	return e:GetHandler():GetCounter(0x1241)>0
end

function c160000895.filter(c,e,tp)
	return c:IsSetCard(0xc911) and c:IsType(TYPE_MONSTER) and not c:IsCode(160000895)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c160000895.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c160000895.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c160000895.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c160000895.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

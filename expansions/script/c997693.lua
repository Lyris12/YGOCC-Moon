--Stellarius Cremate
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x12D9),4,2,nil,nil,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	--Special Summon+Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.acost)
	e2:SetCondition(s.acon)
	e2:SetTarget(s.atg)
	e2:SetOperation(s.aop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.xyzcon)
	e3:SetTarget(s.atktg)
	e3:SetValue(250)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	--extra pierce
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCode(EFFECT_PIERCE)
	e5:SetCondition(s.xyzcon2)
	e5:SetTarget(s.atktg2)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--set facedown
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_POSITION)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_ATTACK_ANNOUNCE)
	e6:SetCondition(s.xyzcon3)
	e6:SetTarget(s.xyztg)
	e6:SetOperation(s.xyzop)
	c:RegisterEffect(e6)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x12D9) and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_LINK)
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x12D9) and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_LINK)
		and Duel.IsExistingMatchingCard(s.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,c)
end


function s.acfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousSetCard(0x12D9)
end
function s.acon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.acfilter,1,nil,tp)
end			
function s.afilter(c,e,tp)
	return c:IsSetCard(0x12D9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.acost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.afilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.aop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.afilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
		if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		local tc=g:GetFirst()
		local fid=c:GetFieldID()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(997693,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		end
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end




function s.xyzcon(e)
	return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetAttribute)>=1
end
function s.xyzcon2(e)
	return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetAttribute)>=2
end
function s.atktg(e,c)
	return c:IsSetCard(0x12D9)
end
function s.atktg2(e,c)
	return c:IsSetCard(0x12D9) 
end
function s.xyzcon3(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and a:IsControler(tp) and d:IsFaceup() and a:IsSetCard(0x12D9) and Duel.GetAttackTarget() and 
	e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetAttribute)>=3
end


function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,Duel.GetAttackTarget(),1,0,0)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	if not tc:IsFacedown() and tc:IsRelateToBattle() then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
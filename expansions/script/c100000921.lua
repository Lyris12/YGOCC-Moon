 --Created and coded by Rising Phoenix
function c100000921.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--special summon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c100000921.spcon)
	e2:SetOperation(c100000921.spop)
	c:RegisterEffect(e2)
		--send replace
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100000921,2))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetCondition(c100000921.repcon)
	e3:SetOperation(c100000921.repop)
	c:RegisterEffect(e3)
	--special summon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(100000921,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c100000921.target)
	e4:SetOperation(c100000921.operation)
	c:RegisterEffect(e4)
		--special summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(100000921,0))
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(c100000921.thtg)
	e5:SetOperation(c100000921.thop)
	c:RegisterEffect(e5)
		--Destroy replace
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(100000921,3))
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetTarget(c100000921.desreptg)
	e6:SetOperation(c100000921.desrepop)
	c:RegisterEffect(e6)
end
function c100000921.repfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsLocation(LOCATION_SZONE) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
function c100000921.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsReason(REASON_REPLACE) and c:IsOnField() and c:IsFaceup()
		and Duel.IsExistingMatchingCard(c100000921.repfilter,tp,LOCATION_SZONE,0,1,c) end
	if Duel.SelectYesNo(tp,aux.Stringid(100000921,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,c100000921.repfilter,tp,LOCATION_SZONE,0,1,1,c)
		e:SetLabelObject(g:GetFirst())
		Duel.HintSelection(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function c100000921.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
function c100000921.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1034) and c:IsAbleToHand()
end
function c100000921.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100000921.thfilter,tp,LOCATION_DECK,0,3,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function c100000921.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c100000921.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,3,3,nil)
		Duel.ConfirmCards(1-tp,sg)
		local tg=sg:RandomSelect(1-tp,1)
		local tc=tg:GetFirst()
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
function c100000921.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
function c100000921.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x1fc0000)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	Duel.RaiseEvent(c,47408488,e,0,tp,0,0)
end
function c100000921.filter(c,e,sp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,sp,true,false)
end
function c100000921.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100000921.filter,tp,LOCATION_SZONE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local gct=Duel.GetMatchingGroupCount(c100000921.filter,tp,LOCATION_SZONE,0,nil,e,tp)
	if ct>gct then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,gct,tp,LOCATION_SZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_SZONE)
	end
end
function c100000921.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct==0 then return end
	local g=Duel.GetMatchingGroup(c100000921.filter,tp,LOCATION_SZONE,0,nil,e,tp)
	local gc=g:GetCount()
	if gc==0 then return end
	if gc<=ct then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,ct,ct,nil)
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end
function c100000921.spfilter(c,code)
	return c:IsCode(code) and c:IsAbleToGraveAsCost()
end
function c100000921.spcon(e,c)
	if c==nil then return true end 
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_ONFIELD+LOCATION_EXTRA)
	if ft<-1 then return false end
	local g1=Duel.GetMatchingGroup(c100000921.spfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,nil,32710364)
	local g2=Duel.GetMatchingGroup(c100000921.spfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,nil,2403771)
	if g1:GetCount()==0 or g2:GetCount()==0 then return false end
	if ft>0 then return true end
	local f1=g1:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_EXTRA)
	local f2=g2:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_EXTRA)
	if ft==-1 then return f1>0 and f2>0
	else return f1>0 or f2>0 end
end
function c100000921.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g1=Duel.GetMatchingGroup(c100000921.spfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,nil,32710364)
	local g2=Duel.GetMatchingGroup(c100000921.spfilter,tp,LOCATION_ONFIELD+LOCATION_EXTRA,0,nil,2403771)
	g1:Merge(g2)
	local g=Group.CreateGroup()
	local tc=nil
	for i=1,2 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		if ft<=0 then
			tc=g1:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_ONFIELD+LOCATION_EXTRA):GetFirst()
		else
			tc=g1:Select(tp,1,1,nil):GetFirst()
		end
		g:AddCard(tc)
		g1:Remove(Card.IsCode,nil,tc:GetCode())
		ft=ft+1
	end
	Duel.SendtoGrave(g,REASON_COST)
end	
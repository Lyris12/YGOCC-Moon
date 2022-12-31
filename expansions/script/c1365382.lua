--Adam Kadmon, l'Ængelico Paradiso
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	c:SetUniqueOnField(LOCATION_MZONE,0,id)
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,12,s.TLcon,{s.TLfil,true},s.TLop)
	--sslimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.tlimit)
	c:RegisterEffect(e0)
	--ignore lim
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_IGNORE_TIMELEAP_HOPT)
	e1:SetCondition(s.igncon)
	c:RegisterEffect(e1)
	--Immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.unval)
	c:RegisterEffect(e2)
	--atk
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_ATKCHANGE+CATEGORY_REMOVE,true,nil,aux.TimeleapSummonedCond,aux.LabelCost,s.tg,s.op)
end
--timeleap summon
function s.TLfil(c)
	return c:IsMonster(TYPE_TIMELEAP) and c:IsFuture(11) and c:IsSetCard(0xae6)
end
function s.TLcon(e,c)
	local tp=e:GetHandlerPlayer()
	local ct1=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)
	return ct1>ct2
end
function s.TLop(e,tp,eg,ep,ev,re,r,rp,c,g)
	Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_TIMELEAP)
	aux.TimeleapHOPT(tp)
end
--
function s.tlimit(e,se,sp,st)
	return st&SUMMON_TYPE_TIMELEAP==SUMMON_TYPE_TIMELEAP
end
function s.igncon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)-Duel.GetLP(1-tp)<=-3000
end

function s.unval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.atkf(c)
	if not c:IsMonster() then return false end
	return c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or c:IsInExtra() and not c:IsFaceup() or c:IsLocation(LOCATION_HAND) and not c:IsPublic()
end
function s.gcheck(sg,c,g,f,min,max,tp)
	return sg:GetClassCount(Card.GetLocation)==#sg and not Duel.IsExistingMatchingCard(aux.NOT(Card.IsAbleToRemove),tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND+LOCATION_GRAVE,0,1,sg,tp,POS_FACEDOWN)
end
	
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND+LOCATION_GRAVE,0):Filter(s.atkf,nil)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		aux.GCheckAdditional=s.gcheck
		local check=g:CheckSubGroup(aux.TRUE,1,4,tp)
		aux.GCheckAdditional=nil
		return check
	end
	local cg=g:Clone()
	e:SetLabel(0)
	aux.GCheckAdditional=s.gcheck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,4,tp)
	aux.GCheckAdditional=nil
	
	Duel.SetTargetCard(sg)
	for tc in aux.Next(sg) do
		if tc:IsLocation(LOCATION_GRAVE) then
			Duel.HintSelection(Group.FromCards(tc))
		else
			Duel.ConfirmCards(1-tp,tc)
		end
		cg:RemoveCard(tc)
		tc:CreateEffectRelation(e)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,0,0)
	Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,e:GetHandler(),1,0,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,cg,#cg,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetTargetCards(e)
	if not c or not c:IsRelateToEffect(e) or not c:IsFaceup() or #sg<=0 then return end
	local atk=sg:GetSum(Card.GetAttack)
	local def=sg:GetSum(Card.GetDefense)
	local _,diff1=c:UpdateATK(atk,true)
	local _,diff2=c:UpdateDEF(def,true)
	for tc in aux.Next(sg) do
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD,1)
	end
	if diff1==atk and diff2==def then
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND+LOCATION_GRAVE,0,sg,tp,POS_FACEDOWN)
		if #rg>0 then
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
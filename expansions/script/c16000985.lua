function c16000985.initial_effect(c)
	 c:EnableReviveLimit()
		local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetCondition(c16000985.fscondition)
	e0:SetOperation(c16000985.fsoperation)
	c:RegisterEffect(e0)

	  --spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16000985,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,16000985)
	e1:SetCondition(c16000985.ctcon)
	e1:SetTarget(c16000985.target)
	e1:SetOperation(c16000985.operation)
	c:RegisterEffect(e1)
	
		  --destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c16000985.reptg)
	e2:SetValue(c16000985.repval)
	e2:SetOperation(c16000985.repop)
	c:RegisterEffect(e2)   
end

function c16000985.cfilter(c)
	return c:IsSetCard(0x885a) and c:IsType(TYPE_MONSTER) and c:IsReason(REASON_EFFECT)
end
function c16000985.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16000985.cfilter,1,nil)
end
function c16000985.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD)
end
function c16000985.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)
	local sg=Group.CreateGroup()
	if g1:GetCount()>0 and (g2:GetCount()==0 or Duel.SelectYesNo(tp,aux.Stringid(16000985,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.HintSelection(sg1)
		sg:Merge(sg1)
	end
	if g2:GetCount()>0 and (sg:GetCount()==0 or Duel.SelectYesNo(tp,aux.Stringid(16000985,2))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg2=g2:RandomSelect(tp,1)
		sg:Merge(sg2)
	end
	Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
end

function c16000985.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION+0x786
end
function c16000985.ffilter(c)
	return  c:IsSetCard(0x885a)  and c:IsType(TYPE_MONSTER) 
end
function c16000985.fscondition(e,g,gc)
	if g==nil then return true end
	if gc then return false end
	return g:IsExists(c16000985.ffilter,3,nil) and (g:IsExists(Card.IsType,1,nil,TYPE_FUSION))
end

function c16000985.fsoperation(e,tp,eg,ep,ev,re,r,rp,gc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	Duel.SetFusionMaterial(eg:FilterSelect(tp,c16000985.ffilter,3,63,nil))
end
function c16000985.repfilter(c,tp)
	return c:IsFaceup() and  c:IsSetCard(0x885a)
		and c:IsControler(tp) and  c:IsLocation(LOCATION_ONFIELD) and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
function c16000985.repfilterxxl(c,e)
	return c:IsSetCard(0x885a)
		and c:IsAbleToRemove()
end
function c16000985.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c16000985.repfilter,1,nil,tp)  and Duel.IsExistingMatchingCard(c16000985.repfilterxxl,tp,LOCATION_HAND ,0,1,c,e) end
   if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
		local g=Duel.SelectMatchingCard(tp,c16000985.repfilterxxl,tp,LOCATION_HAND,0,1,1,c,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
function c16000985.repval(e,c)
	return c16000985.repfilter(c,e:GetHandlerPlayer())
end
function c16000985.repop(e,tp,eg,ep,ev,re,r,rp)
	  local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
		 Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
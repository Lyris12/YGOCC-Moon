--MMS - Cancello Asse
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0xd71)
	c:Activate()
	--stats
	c:UpdateATKDEFField(400,400,nil,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,0xd71))
	--counter
	c:SummonedFieldTrigger(s.cfilter,false,false,true,false,0,CATEGORY_COUNTER,true,LOCATION_FZONE,nil,
		nil,
		nil,
		aux.AddCounterTarget(0xd71,1,SUBJECT_THIS_CARD),
		aux.AddCounterOperation(0xd71,1,SUBJECT_THIS_CARD)
	)
	--Destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTarget(s.desreptg)
	e1:SetOperation(s.desrepop)
	c:RegisterEffect(e1)
	--self negate
	c:CreateNegateEffect(false,0,s.chfilter,1,LOCATION_FZONE,nil,
		nil,
		aux.RemoveCounterSelfCost(0xd71),
		aux.SearchTarget(s.thfilter),
		aux.SearchOperation(s.thfilter),
		CATEGORY_SEARCH+CATEGORY_TOHAND
	)
	--fusion summon
	c:Ignition(2,CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE,nil,LOCATION_FZONE,1,
		nil,
		nil,
		aux.FusionSummonTarget(aux.Filter(Card.IsSetCard,0xd71),aux.Filter(Card.IsOnField),{aux.TRUE,LOCATION_GRAVE}),
		aux.FusionSummonOperation(aux.Filter(Card.IsSetCard,0xd71),aux.Filter(Card.IsOnField),{aux.TRUE,LOCATION_GRAVE},s.fusop)
	)
end
function s.cfilter(c,e,tp,eg,ep,ev,re)
	return c:IsFaceup() and c:IsMonster(TYPE_FUSION) and c:IsSetCard(0xd71) and c:GetSummonType()&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
		and (not c:IsReason(REASON_EFFECT) or not re or not re:GetHandler() or not re:GetHandler():IsCode(id))
end

function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE)
		and e:GetHandler():IsCanRemoveCounter(tp,0xd71,1,REASON_EFFECT+REASON_REPLACE)
	end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(tp,0xd71,1,REASON_EFFECT+REASON_REPLACE)
end

function s.chfilter(rc,re,e,tp,eg,ep,ev,r,rp)
	local ex,tg,tc,p,loc=Duel.GetOperationInfo(ev,CATEGORY_TOHAND)
	local ex2,_,_,p2,v2=Duel.GetOperationInfo(ev,CATEGORY_DRAW)
	if not ex and not ex2 then return false end
	if ex2 and (p2==tp or p2==PLAYER_ALL) and v2>0 then return true end
	if not tg then
		return tc>0 and (p==tp or p==PLAYER_ALL) and loc and loc&LOCATION_DECK==LOCATION_DECK
	else
		return tc+tg:FilterCount(aux.PLChk,nil,tp,LOCATION_DECK)-#tg>0
	end
end
function s.thfilter(c)
	return c:IsSetCard(0xd71) and not c:IsCode(id)
end

function s.fusop(mat,fc,fr,e,tp,eg,ep,ev,re,r,rp)
	local rg=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,fr)
		mat:Sub(rg)
	end
	if #mat>0 then
		Duel.SendtoGrave(mat,fr)
	end
end
--MMS - Sherlock Holmes
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,s.mfilter1,s.ffilter,true)
	--destroy
	c:SummonedTrigger(false,false,true,false,0,CATEGORY_HANDES,true,true,
		nil,
		nil,
		s.target,
		s.operation
	)
	--bounce and destroy
	c:Quick(false,1,CATEGORY_TOHAND+CATEGORY_DESTROY,EFFECT_FLAG_CARD_TARGET,nil,LOCATION_MZONE,1,
		nil,
		nil,
		aux.Target(s.thfilter,LOCATION_ONFIELD,0,1,1,nil,nil,CATEGORY_TOHAND,nil,nil,aux.Info(CATEGORY_DESTROY,1,PLAYER_ALL,LOCATION_ONFIELD)),
		aux.CreateOperation(
			aux.SendToHandOperation(SUBJECT_IT),
			CONJUNCTION_AND_IF_YOU_DO,
			aux.DestroyOperation(aux.TRUE,LOCATION_ONFIELD,LOCATION_ONFIELD)
		),
		RELEVANT_TIMINGS
	)
end
function s.mfilter1(c)
	return c:IsFusionSetCard(0xd71) and c:IsFusionType(TYPE_MONSTER)
end
function s.ffilter(c,fc,sub,mg,sg)
	local tp=fc:GetControler()
	return Duel.IsExistingMatchingCard(Card.IsAttribute,tp,0,LOCATION_MZONE,1,nil,c:GetFusionAttribute())
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,0,LOCATION_HAND,1,nil,REASON_EFFECT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	Duel.SetTargetParam(Duel.SelectOption(tp,70,71,72))
end
function s.filter(c,typ)
	return c:IsDiscardable(REASON_EFFECT) and c:IsType(typ)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	if #g==0 then return end
	local opt=Duel.GetTargetParam()
	if not opt then return end
	Duel.ConfirmCards(tp,g)
	local list={TYPE_MONSTER,TYPE_SPELL,TYPE_TRAP}
	local typ=list[opt+1]
	if g:IsExists(s.filter,1,nil,typ) then
		Duel.BreakEffect()
		local sg=g:FilterSelect(tp,s.filter,1,1,nil,typ)
		if #sg>0 then
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
		end
	end
	Duel.ShuffleHand(1-tp)
end

function s.thfilter(c,e,tp)
	return c:IsFaceup() and c:IsST(TYPE_CONTINUOUS+TYPE_FIELD) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
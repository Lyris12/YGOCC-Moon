--Esorcista del Maestro dei Sigilli, Nori
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	c:SummonedTrigger(false,true,true,false,0,CATEGORIES_SEARCH,true,true,
		nil,
		aux.LabelCost,
		s.thtg,
		s.thop
	)
	--normal summon
	c:Ignition(3,CATEGORY_SUMMON,nil,LOCATION_MZONE,true,
		nil,
		s.sumcost,
		aux.NSTarget(aux.Filter(Card.IsSetCard,0x7ec)),
		aux.NSOperation(aux.Filter(Card.IsSetCard,0x7ec))
	)
end
function s.thfilter(c,tp,val)
	return c:IsMonster() and c:IsSetCard(0x7eb) and (not tp or c:IsCanEngage(tp,true)) and c:IsAbleToHand()
		and (not val or c:IsCanUpdateEnergy(val,tp,REASON_EFFECT) or c:IsCanUpdateEnergy(-val,tp,REASON_EFFECT))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return en and en:IsMonster() and en:IsSetCard(0x7eb) and en:IsCanChangeEnergy(0,tp,REASON_COST)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp,en:GetEnergy())
	end
	e:SetLabel(0)
	local e1=en:GetEnergy()
	local _,e2=en:ChangeEnergy(0,tp,REASON_COST,true,e:GetHandler())
	Duel.SetTargetParam(math.abs(e2-e1))
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local val=Duel.GetTargetParam()
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp,val)
	if #g==0 then
		g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g==0 then
			g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		end
	end
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) and tc:IsCanEngage(tp) then
			tc:Engage(e,tp)
			if tc:IsEngaged() and val and val~=0 then
				local b1=tc:IsCanUpdateEnergy(val,tp,REASON_EFFECT)
				local b2=tc:IsCanUpdateEnergy(-val,tp,REASON_EFFECT)
				if not b1 and not b2 then return end
				local opt=aux.Option(id,tp,1,b1,b2)
				if not opt then return end
				local ct = (opt==0) and val or -val
				tc:UpdateEnergy(ct,tp,REASON_EFFECT,true,e:GetHandler())
			end
		end
	end
end

function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=Duel.GetEngagedCard(tp)
	if chk==0 then
		return dc and dc:IsMonster() and dc:IsSetCard(0x7eb) and dc:IsCanUpdateEnergy(-3,tp,REASON_COST)
	end
	dc:UpdateEnergy(-3,tp,REASON_COST,true)
end
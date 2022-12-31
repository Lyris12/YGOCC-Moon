--Grandioso Maestro dei Sigilli, Hisaki
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--ss
	c:Quick(false,0,CATEGORY_SPECIAL_SUMMON,nil,nil,LOCATION_HAND,nil,
		aux.MainPhaseCond(),
		s.spcost,
		aux.SSTarget(SUBJECT_THIS_CARD),
		aux.SSOperation(SUBJECT_THIS_CARD)
	)
	--protection
	c:EffectProtectionField(PROTECTION_FROM_OPPONENT,nil,LOCATION_MZONE,0,aux.TargetBoolFunction(Card.IsSetCard,0x7eb))
	--ss
	c:CreateNegateEffect(true,nil,s.negfilter,1,LOCATION_MZONE,1,
		nil,
		s.negcost,
		nil,
		CATEGORY_REMOVE
	)
end
function s.cfilter(c,tp)
	return c:IsSetCard(0x7ea) and c:IsAbleToGraveAsCost() and c:NotOnFieldOrFaceup() and Duel.GetMZoneCount(tp,c)>0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		if not en or not en:IsCanUpdateEnergy(-2,tp,REASON_COST) then return false end
		local exc=Group.FromCards(e:GetHandler())
		if en:GetEnergy()==2 then
			exc:AddCard(en)
		end
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,exc,tp)
	end
	en:UpdateEnergy(-2,tp,REASON_COST,true,e:GetHandler())
	local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end

function s.negfilter(rc,re,e,tp,eg,ep,ev,r,rp)
	local p,loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_LOCATION)
	return p==1-tp and loc&(LOCATION_HAND+LOCATION_GRAVE)>0
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		return en and en:IsMonster() and en:IsSetCard(0x7eb) and en:IsCanUpdateEnergy(-3,tp,REASON_COST)
	end
	en:UpdateEnergy(-3,tp,REASON_COST,true,e:GetHandler())
end
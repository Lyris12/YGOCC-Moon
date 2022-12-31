--Prestigiatore del Maestro dei Sigilli, Susumu
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	c:Ignition(1,CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND,EFFECT_FLAG_CARD_TARGET,LOCATION_MZONE,true,
		nil,
		aux.LabelCost,
		s.sptg,
		s.spop
	)
	--normal summon
	c:Ignition(1,nil,nil,LOCATION_HAND+LOCATION_MZONE,true,
		s.encon,
		aux.ToGraveSelfCost,
		s.entg,
		s.enop
	)
end
function s.spfilter(c,e,tp,en,lv)
	return c:IsMonster() and c:IsSetCard(0x7ec) and c:HasLevel() and c:GetLevel()>0 and c:IsLevelBelow(6)
		and (not lv or c:IsLevel(lv)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not en or en:IsCanUpdateEnergy(-c:GetLevel(),tp,REASON_COST)) 
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return c:IsAbleToHand() and en and en:IsMonster() and en:IsSetCard(0x7eb)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,en)
	end
	e:SetLabel(0)
	local nums={}
	for i=1,math.min(6,en:GetEnergy()) do
		if Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,en,i) then
			table.insert(nums,-i)
		end
	end
	if #nums>0 then
		local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
		local _,diff=en:UpdateEnergy(ct,tp,REASON_COST,true,e:GetHandler())
		if math.abs(diff)>0 then
			local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,nil,math.abs(diff))
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_GRAVE)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,c:GetControler(),c:GetLocation())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToChain() then return end
	local c=e:GetHandler()
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToChain() then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

function s.encon(e,tp)
	e:SetLabel(1)
	local en=Duel.GetEngagedCard(tp)
	return en and en:IsMonster() and en:IsSetCard(0x7eb)
end
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		local already_checked=(e:GetLabel()==1)
		e:SetLabel(0)
		return (already_checked or (en and en:IsMonster())) and en:IsCanUpdateEnergy(3,tp,REASON_EFFECT)
	end
	e:SetLabel(0)
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard(tp)
	if en then
		en:UpdateEnergy(3,tp,REASON_EFFECT,true,e:GetHandler())
	end
end
--Discepola del Maestro dei Sigilli, Hitomi
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	c:SSProc(0,nil,LOCATION_HAND,nil,s.spcon)
	--normal summon
	c:Ignition(1,CATEGORIES_SEARCH,nil,LOCATION_MZONE,true,
		nil,
		aux.LabelCost,
		s.thtg,
		s.thop
	)
end
function s.spcon(e,c,tp)
	local en=Duel.GetEngagedCard(tp)
	return en and en:IsMonster() and en:IsSetCard(0x7eb) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x7ec),tp,LOCATION_MZONE,0,1,nil)
end

function s.thfilter(c,tp,en,lv,ignore_cost)
	return c:IsMonster() and c:IsSetCard(0x7eb,0x7ec) and c:NotBanishedOrFaceup() and c:HasLevel() and c:GetLevel()>0
		and (not lv or c:IsLevel(lv)) and c:IsAbleToHand()
		and (ignore_cost or en:IsCanUpdateEnergy(-c:GetLevel(),tp,REASON_COST)) 
		and (not en or not c:IsCode(en:GetCode()))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return en and en:IsMonster() and en:IsSetCard(0x7eb)
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,LOCATION_REMOVED,1,nil,tp,en)
	end
	e:SetLabel(0)
	local nums={}
	for i=1,en:GetEnergy() do
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,LOCATION_REMOVED,1,nil,tp,en,i) then
			table.insert(nums,-i)
		end
	end
	if #nums>0 then
		local ct=Duel.AnnounceNumber(tp,table.unpack(nums))
		local _,diff=en:UpdateEnergy(ct,tp,REASON_COST,true,e:GetHandler())
		Duel.SetTargetParam(math.abs(diff))
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local en=Duel.GetEngagedCard()
	local val=Duel.GetTargetParam()
	if not val then return end
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,tp,en,val,true)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
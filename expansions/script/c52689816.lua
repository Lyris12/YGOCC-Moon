--Emergency Lifeline
--Vitavìa di Emergenza
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,5)
	--[[[-1]: (Quick Effect): Target 1 Psychic monster, OR 1 Drive Monster, you control; your opponent gains 1200 LP,
	also banish that monster, face-up or face-down, but return it to the field during the End Phase.]]
	c:DriveEffect(-1,0,CATEGORY_RECOVER|CATEGORY_REMOVE,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.rmtg,
		s.rmop
	)
	--[[-4]: Pay LP in multiples of 1000 (max. 3000); you cannot Special Summon monsters for the rest of this turn, except Psychic monsters,
	also add from your Deck or GY to your hand, 1 Psychic monster with an effect that can be activated by paying LP,
	whose Level is equal to the LP you paid to activate this effect, divided by 1000.]]
	c:DriveEffect(-4,1,{CATEGORIES_SEARCH,CATEGORY_PAYLP},EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.thtg,
		s.thop,
		nil,
		true
	)
	--[[If this card is Drive Summoned: You can add 1 "Emergency Teleport" from your Deck or GY to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(3)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(aux.DriveSummonedCond)
	e1:SetTarget(s.thtg2)
	e1:SetOperation(s.thop2)
	c:RegisterEffect(e1)
	--[[If your LP are lower than half your opponent's LP, you do not have to pay LP to activate the effects of Psychic monsters.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LPCOST_CHANGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.costcon)
	e2:SetValue(s.costchange)
	c:RegisterEffect(e2)
end
if not s.ValidMonsters then
	s.ValidMonsters = {
	16191953,1834753,12408276,87622767,58453942,93302695,67050396,39091951,98147766,11232355,89547299,31061682,21454943,13258285,1274455,50642380,82041999,19535693,27995943,
	86013171,59575539,56907986,52430902,58695102,96782886,22171591,64280356,19251411,19251401,19251400,47511800
	}
end

function s.rmfilter(c)
	return c:IsFaceup() and (c:IsRace(RACE_PSYCHIC) or c:IsType(TYPE_DRIVE)) and c:IsAbleToRemove(tp,POS_FACEUP|POS_FACEDOWN,REASON_EFFECT|REASON_TEMPORARY)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and s.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,1-tp,1200)
	Duel.SetCardOperationInfo(g,CATEGORY_REMOVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(1-tp,1200,REASON_EFFECT)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		local pos=0
		if tc:IsAbleToRemove(tp,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY) then
			pos=POS_FACEUP_ATTACK
		end
		if tc:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT|REASON_TEMPORARY) then
			pos=pos|POS_FACEDOWN_ATTACK
		end
		if pos==0 then return end
		pos=Duel.SelectPosition(tp,tc,pos)
		Duel.BanishUntil(tc,pos,PHASE_END,id)
	end
end

function s.thfilter(c,tp,prelv)
	if c:HasFlagEffectLabel(id+100,0) or not c:IsMonster() or c:GetOriginalType()&TYPE_EFFECT==0 or (prelv and not c:IsLevel(prelv)) then return false end
	local lv = type(prelv)=="number" and prelv or c:GetLevel()
	local res = c:IsRace(RACE_PSYCHIC) and c:IsLevelBelow(3) and c:IsAbleToHand() and Duel.CheckLPCost(tp,lv*1000,true)
	if not c:HasFlagEffect(id+100) then
		local res2=false
		if aux.FindInTable(s.ValidMonsters,c:GetOriginalCode()) then
			res2=true
		elseif global_card_effect_table[c] then
			for _,e in ipairs(global_card_effect_table[c]) do
				if aux.GetValueType(e)=="Effect" and e.GetLabel and e:IsActivated() and e:GetReset()==0 then
					if e:GetCustomCategory()&CATEGORY_PAYLP>0 then
						res2=true
						break
					end
				end
			end
		end
		if not res2 then
			c:RegisterFlagEffect(id+100,0,EFFECT_FLAG_IGNORE_IMMUNE,1,0)
			return false
		else
			c:RegisterFlagEffect(id+100,0,EFFECT_FLAG_IGNORE_IMMUNE,1,1)
		end
	end
	return res
end
function s.thfilter2(c,lv)
	if c:HasFlagEffectLabel(id+100,0) then return false end
	local res = c:IsMonster() and c:GetOriginalType()&TYPE_EFFECT==TYPE_EFFECT and c:IsRace(RACE_PSYCHIC) and c:IsLevel(lv) and c:IsAbleToHand()
	if not c:HasFlagEffect(id+100) then
		local res2=false
		if aux.FindInTable(s.ValidMonsters,c:GetOriginalCode()) then
			res2=true
		elseif global_card_effect_table[c] then
			for _,e in ipairs(global_card_effect_table[c]) do
				if aux.GetValueType(e)=="Effect" and e.GetLabel and e:IsActivated() and e:GetReset()==0 then
					if e:GetCustomCategory()&CATEGORY_PAYLP>0 then
						res2=true
						break
					end
				end
			end
		end
		if not res2 then
			c:RegisterFlagEffect(id+100,0,EFFECT_FLAG_IGNORE_IMMUNE,1,0)
			return false
		else
			c:RegisterFlagEffect(id+100,0,EFFECT_FLAG_IGNORE_IMMUNE,1)
		end
	end
	return res
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp)
	end
	e:SetLabel(0)
	local av_cost={}
	for lv=1,3 do
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp,lv) then
			table.insert(av_cost,lv*1000)
		end
	end
	local cost=Duel.AnnounceNumber(tp,table.unpack(av_cost))
	Duel.PayLPCost(tp,cost)
	Duel.SetTargetParam(cost/1000)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local lv=Duel.GetTargetParam()
	if not lv then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,lv)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
function s.splimit(e,c)
	return not c:IsRace(RACE_PSYCHIC)
end

function s.thfilter3(c)
	return c:IsCode(67723438) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter3),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end

function s.costcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)<math.ceil(Duel.GetLP(1-tp)/2)
end
function s.costchange(e,re,rp,val)
	local rc=re:GetHandler()
	if re and re:IsActivated() and re:IsActiveType(TYPE_MONSTER) and rc:IsRace(RACE_PSYCHIC) then
		return 0
	else
		return val
	end
end

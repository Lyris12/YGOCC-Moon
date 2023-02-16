--Gardrenial Cycle - Summer
local ref,id=GetID()
Duel.LoadScript("GardrenialCommons.lua")
function ref.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(ref.acttg)
	e1:SetOperation(ref.actop)
	c:RegisterEffect(e1)
	--Declare Race
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(ref.dectg)
	e2:SetOperation(ref.decop)
	c:RegisterEffect(e2)
end

--Activate
function ref.thfilter(c,e) return c:IsAbleToHand() and c:IsCanBeEffectTarget(e) end
function ref.thgfilter(g) return g:GetClassCount(Card.GetControler)==#g end
function ref.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	local g=Duel.GetMatchingGroup(ref.thfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return g:CheckSubGroup(ref.thgfilter,1,2) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tg=g:SelectSubGroup(tp,ref.thgfilter,false,1,2)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,#tg,0,0)
end
function ref.sumfilter(c,codes)
	return c:IsSummonable(true,nil) and not c:IsRace(table.unpack(codes)) --c:IsCode(table.unpack(codes))
end
function ref.actop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 then
		local codes={}
		local players={}
		players[0],players[1] = 0,0
		local tc=tg:GetFirst()
		while tc do
			table.insert(codes,tc:GetRace())
			players[tc:GetOwner()]=1
			tc=tg:GetNext()
		end
		if Duel.SendtoHand(tg,nil,REASON_EFFECT)~=0 then
			for p=0,1 do
				if players[p]==1 and Duel.IsExistingMatchingCard(ref.sumfilter,p,LOCATION_HAND,0,1,nil,codes) and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
					Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SUMMON)
					local g=Duel.SelectMatchingCard(p,ref.sumfilter,p,LOCATION_HAND,0,1,1,nil,codes)
					if #g>0 then Duel.Summon(p,g:GetFirst(),true,nil) end
				end
			end
		end
	end
end

--Declare Race
function ref.dectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not (Gardrenial.NSInsect(tp) and Gardrenial.NSPlant(tp)) end
	local ar=Duel.AnnounceRace(tp,1,RACE_PLANT+RACE_INSECT)
	e:SetLabel(ar)
end
function ref.decop(e,tp,eg,ep,ev,re,r,rp)
	local ar=e:GetLabel()
	Gardrenial.EnableNS(tp,ar)
end

